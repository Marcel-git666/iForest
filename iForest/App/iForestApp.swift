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
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "iForestDataModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
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
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

@main
struct iForestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @ObservedObject private var appCoordinator = AppCoordinator()
    //@StateObject private var appState = AppState()
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
                .environment(\.managedObjectContext, context)
                //.environmentObject(AppState.shared)
                .onAppear {
                    logger.info("🦈 AppCoordinator has appeared.")
                }
                .ignoresSafeArea(.all)
        }
    }
}
