//
//  Coordinator.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import Foundation

protocol Coordinator: AnyObject, DeeplinkHandling {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func release(coordinator: Coordinator) {
        childCoordinators.removeAll {
            $0 === coordinator
        }
    }
    
    func startChildCoordinator(_ childCoordinator: Coordinator) {
        print("Starting child coordinator: \(childCoordinator)")
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
    
    func handleDeeplink(_ deeplink: Deeplink) {
        childCoordinators.forEach { $0.handleDeeplink(deeplink) }
    }
}
