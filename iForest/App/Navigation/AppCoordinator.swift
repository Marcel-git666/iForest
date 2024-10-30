//
//  AppCoordinator.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import Combine
import os
import UIKit

protocol AppCoordinating: ViewControllerCoordinator {}

final class AppCoordinator: AppCoordinating, ObservableObject {
    // MARK: Private properties
    private lazy var cancellables = Set<AnyCancellable>()
    private lazy var keychainService = KeychainService(keychainManager: KeychainManager())
    private lazy var logger = Logger()
    // Persist coordinators to avoid recreating them
    private lazy var projectCoordinator = makeProjectFlow()
    private lazy var loginCoordinator = makeLoginFlow()
    
    // MARK: Public properties
    var childCoordinators = [Coordinator]()
//    var accessLevel: AccessLevel {
//        get { appState.accessLevel }
//        set { appState.accessLevel = newValue }
//    }
    
    // Root view controller, dynamically set based on access level
    var rootViewController: UIViewController {
        switch AppState.shared.accessLevel {
        case .authorized, .guest:
            return projectCoordinator.rootViewController
        case .none:
            return loginCoordinator.rootViewController
        }
    }
    
    // MARK: Lifecycle
    init() {
        if (try? keychainService.fetchAuthData()) != nil {
            AppState.shared.accessLevel = .authorized
        }
        logger.info("AccessLevel = \(AppState.shared.accessLevel)")
    }
}

extension AppCoordinator {
    func start() {
    }
}

// MARK: - Factory methods
extension AppCoordinator {
    
    func makeProjectFlow() -> ViewControllerCoordinator {
        let projectCoordinator = ProjectNavigationCoordinator()
        startChildCoordinator(projectCoordinator)
        projectCoordinator.eventPublisher.sink { [weak self] event in
            self?.handleEvent(event)
        }
        .store(in: &cancellables)
        return projectCoordinator
    }
    
    func makeLoginFlow() -> ViewControllerCoordinator {
        let loginCoordinator = LoginNavigationCoordinator()
        startChildCoordinator(loginCoordinator)
        loginCoordinator.eventPublisher.sink { [weak self] event in
            self?.handleEvent(event)
        }
        .store(in: &cancellables)
        return loginCoordinator
    }
    
    
    func handleDeeplink(deeplink: Deeplink) {
        childCoordinators.forEach { $0.handleDeeplink(deeplink) }
    }
}

extension AppCoordinator {
    func handleEvent(_ event: LoginNavigationCoordinatorEvent) {
        switch event {
        case let .signedIn(coordinator):
            logger.info("User signed in.")
            AppState.shared.accessLevel = .authorized
            updateRootViewController()
        case let .proceedWithoutLogin(coordinator):
            logger.info("User skipped login; proceeding as guest.")
            AppState.shared.accessLevel = .guest
            updateRootViewController()
        case let .logout(coordinator):
            logger.info("User logged out.")
            AppState.shared.accessLevel = .none
            updateRootViewController()
        }
    }
    
    func handleEvent(_ event: ProjectNavigationCoordinatorEvent) {
        switch event {
        case let .logout(coordinator):
            logger.info("User logged out from Project screen.")
            AppState.shared.accessLevel = .none
            updateRootViewController()
        case .login:
            logger.info("User requested login from Project screen.")
            AppState.shared.accessLevel = .none
            updateRootViewController()
        }
    }
    
    private func updateRootViewController() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
        }
    }
}
