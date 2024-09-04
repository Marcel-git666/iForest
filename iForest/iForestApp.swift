//
//  iForestApp.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import SwiftUI

@main
struct iForestApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appCoordinator.path) {
                appCoordinator.view()
                    .navigationDestination(for: ProjectsCoordinator.self) { coordinator in
                        coordinator.view()
                    }
                    .navigationDestination(for: StandsCoordinator.self) { coordinator in
                        coordinator.view()
                    }
                    .navigationDestination(for: TreesCoordinator.self) { coordinator in
                        coordinator.view()
                    }
            }
            .environmentObject(appCoordinator)
        }
    }
}
