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
    private(set) lazy var rootViewController: UIViewController = {
        if (accessLevel != .none) {
            makeProjectFlow().rootViewController
        } else {
            makeLoginFlow().rootViewController
        }
    }()
    private lazy var cancellables = Set<AnyCancellable>()
    private lazy var keychainService = KeychainService(keychainManager: KeychainManager())
    private lazy var logger = Logger()
    // MARK: Public properties
    var childCoordinators = [Coordinator]()
    @Published var accessLevel: AccessLevel = .none
    
    // MARK: Lifecycle
    init() {
        if (try? keychainService.fetchAuthData()) != nil {
            accessLevel = .authorized
        }
        logger.info("AccessLevel = \(self.accessLevel)")
    }
}

extension AppCoordinator {
    func start() {
        setupAppUI()
        
    }
    
    func setupAppUI() {
        // Set background color for Tab Bar
        UITabBar.appearance().backgroundColor = .systemBrown
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = .white
        
        // Set tintColor for navigation bar items (back buttons, bar buttons, etc.)
        UINavigationBar.appearance().tintColor = .blue // Choose a color visible in both light/dark mode
        
        // Set navigation bar background color based on the current interface style
        UINavigationBar.appearance().backgroundColor = UIColor.systemBackground
        
        // Adjust title text color for navigation bar
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.label // Adapts to light/dark mode
        ]
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
            rootViewController = makeProjectFlow().rootViewController
            release(coordinator: coordinator)
            accessLevel = .authorized
        case let .proceedWithoutLogin(coordinator):
            logger.info("User skipped login; proceeding as guest.")
            rootViewController = makeProjectFlow().rootViewController
            release(coordinator: coordinator)
            accessLevel = .guest
        case let .logout(coordinator):
            logger.info("User logged out.")
            rootViewController = makeLoginFlow().rootViewController
            release(coordinator: coordinator)
            accessLevel = .none
        }
    }
    
    func handleEvent(_ event: ProjectNavigationCoordinatorEvent) {
        switch event {
        case let .logout(coordinator):
            logger.info("User logged out from Project screen.")
            accessLevel = .none
            rootViewController = makeLoginFlow().rootViewController
            release(coordinator: coordinator)
        case let .login(coordinator):
            logger.info("User requested login from Project screen.")
            rootViewController.present(makeLoginFlow().rootViewController, animated: true)
        }
    }
}
