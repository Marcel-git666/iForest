//
//  MainTabBarCoordinator.swift
//  iForest
//
//  Created by Marcel Mravec on 01.11.2024.
//

import Combine
import os
import SwiftUI
import UIKit

final class MainTabBarCoordinator: NSObject, TabBarControllerCoordinator {
    var childCoordinators = [Coordinator]()
    private(set) lazy var tabBarController = makeTabBarController()
    private let eventSubject = PassthroughSubject<MainTabBarEvent, Never>()
    private lazy var cancellables = Set<AnyCancellable>()
    private lazy var logger = Logger()
        
    deinit {
        logger.info("❌ Deinit MainTabCoordinator")
    }
}

extension MainTabBarCoordinator {
    func start() {
        tabBarController.viewControllers = [
            setupProjectView().rootViewController
        ]
    }
    
    func handleDeeplink(_ deeplink: Deeplink) {
        switch deeplink {
        case let .onboarding(page):
            let coordinator = makeOnboardingFlow(page: page)
            startChildCoordinator(coordinator)
            tabBarController.present(coordinator.rootViewController, animated: true)
        default:
            break
        }
        childCoordinators.forEach { $0.handleDeeplink(deeplink) }
    }
}

private extension MainTabBarCoordinator {
    func makeOnboardingFlow(page: Int) -> ViewControllerCoordinator {
        let coordinator = OnboardingNavigationCoordinator()
        coordinator.eventPublisher
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
            .store(in: &cancellables)
        return coordinator
    }
    
    func handleEvent(_ event: OnboardingNavigationCoordinatorEvent) {
        switch event {
        case let .dismiss(coordinator):
            release(coordinator: coordinator)
        }
    }
    
    func makeTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        let appearance = UITabBarAppearance()
        appearance.backgroundEffect = .none
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.delegate = self
        return tabBarController
    }
    
    func setupProjectView() -> ViewControllerCoordinator {
        let projectCoordinator = ProjectNavigationCoordinator()
        startChildCoordinator(projectCoordinator)
        projectCoordinator.eventPublisher
                .sink { [weak self] event in
                    self?.handleEvent(event)  // Pass events to MainTabBarCoordinator's handleEvent
                }
                .store(in: &cancellables)
        projectCoordinator.rootViewController.tabBarItem = UITabBarItem(
            title: "Projects",
            image: UIImage(systemName: "list.bullet.rectangle.portrait"),
            tag: 0
        )
        
        return projectCoordinator
    }
    
}

extension MainTabBarCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController === tabBarController.viewControllers?.last {
            // rootViewController.showInfoAlert(title: "Last view controller alert.")
        }
    }
}

// MARK: - Handling events
private extension MainTabBarCoordinator {
    func handleEvent(_ event: ProjectNavigationCoordinatorEvent) {
        switch event {
        case .logout:
            logger.info("Project navigation Coordiantor Event .logout")
            eventSubject.send(.logout(self))
        case .login:
            logger.info("Project navigation Coordiantor Event .login")
            eventSubject.send(.login(self))
        }
    }
}

extension MainTabBarCoordinator: EventEmitting {
    var eventPublisher: AnyPublisher<MainTabBarEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
}
