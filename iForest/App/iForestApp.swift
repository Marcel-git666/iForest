//
//  iForestApp.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import CoreData
import FirebaseCore
import os
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    // Delegate pattern
    weak var deeplinkHandler: DeeplinkHandling?
    
    
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        UserDefaults.standard.set(true, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        deeplinkFromService()
        return true
    }
    
    func deeplinkFromService() { // swiftlint:disable:next no_magic_numbers
        if !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.deeplinkHandler?.handleDeeplink(.onboarding(page: 0))
            }
        }
    }
    
    func saveContext() {
        CoreDataStack.shared.saveContext()
    }
}

@main
struct iForestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @ObservedObject private var appCoordinator = AppCoordinator()
    @StateObject private var appState = AppState()
    private let logger = Logger()
    let context = CoreDataStack.shared.context
    
    init() {
        appCoordinator.start()
        delegate.deeplinkHandler = appCoordinator
    }
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView(coordinator: appCoordinator )
                //.id(appCoordinator.appState)
                .environment(\.managedObjectContext, CoreDataStack.shared.context)
                .environmentObject(AppState.shared)
                .onAppear {
                    logger.info("🦈 AppCoordinator has appeared.")
                }
                .ignoresSafeArea(.all)
        }
    }
}
