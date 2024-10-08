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
    private(set) lazy var rootViewController: UIViewController = {
        if isAuthorized {
            makeProjectFlow().rootViewController
        } else {
            makeLoginFlow().rootViewController
        }
    }()
    var childCoordinators = [Coordinator]()
    private lazy var cancellables = Set<AnyCancellable>()
    private lazy var keychainService = KeychainService(keychainManager: KeychainManager())
    private lazy var logger = Logger()
    @Published var isAuthorized = false
    
    // MARK: Lifecycle
    init() {
        isAuthorized = (try? keychainService.fetchAuthData()) != nil
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
    
    func makeLoginFlow() -> ViewControllerCoordinator {
        let loginCoordinator = LoginNavigationCoordinator()
        startChildCoordinator(loginCoordinator)
        loginCoordinator.eventPublisher.sink { [weak self] event in
            self?.handleEvent(event)
        }
        .store(in: &cancellables)
        return loginCoordinator
    }
    
    func makeProjectFlow() -> ViewControllerCoordinator {
        let projectCoordinator = ProjectNavigationCoordinator()
        startChildCoordinator(projectCoordinator)
        projectCoordinator.eventPublisher.sink { [weak self] event in
            self?.handleEvent(event)
        }
        .store(in: &cancellables)
        return projectCoordinator
    }
    
    func handleDeeplink(deeplink: Deeplink) {
        childCoordinators.forEach { $0.handleDeeplink(deeplink) }
    }
}

extension AppCoordinator {
    func handleEvent(_ event: LoginNavigationCoordinatorEvent) {
        switch event {
        case let .signedIn(coordinator):
            rootViewController = makeProjectFlow().rootViewController
            release(coordinator: coordinator)
            isAuthorized = true
        }
    }
    
    func handleEvent(_ event: ProjectNavigationCoordinatorEvent) {
        switch event {
        case let .logout(coordinator):
            rootViewController = makeLoginFlow().rootViewController
            release(coordinator: coordinator)
            isAuthorized = false
        default:
            break
        }
    }
}
