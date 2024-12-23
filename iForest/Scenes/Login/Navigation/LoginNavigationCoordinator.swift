//
//  LoginNavigationCoordinator.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import Combine
import os
import SwiftUI
import UIKit

protocol LoginCoordinating: NavigationControllerCoordinator {}

final class LoginNavigationCoordinator: NSObject, LoginCoordinating {
    private(set) var navigationController: UINavigationController = CustomNavigationController()
    private lazy var cancellables = Set<AnyCancellable>()
    private let eventSubject = PassthroughSubject<LoginNavigationCoordinatorEvent, Never>()
    private let logger = Logger()
    var childCoordinators = [Coordinator]()
    
    // MARK: Lifecycle
    deinit {
        logger.info("❌ Deinit LoginNavigationCoordinator")
    }
    
    override init() {
        super.init()
        logger.info("🦈 Init LoginNavigationCoordinator")
    }
    
    func start() {
        navigationController.setViewControllers([makeLogin()], animated: true)
    }
}

// MARK: - Factories
private extension LoginNavigationCoordinator {
    func makeLogin() -> UIViewController {
        let store = LoginViewStore(keychainService: KeychainService(keychainManager: KeychainManager()), authManager: FirebaseAuthManager())
        store.eventPublisher
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
            .store(in: &cancellables)
        return UIHostingController(rootView: LoginView(store: store))
    }
}

private extension LoginNavigationCoordinator {
    func handleEvent(_ event: LoginViewEvent) {
        switch event {
        case .loggedIn:
            eventSubject.send(.signedIn)
        case .loggedOut:
            eventSubject.send(.proceedWithoutLogin)
        }
    }
}

extension LoginNavigationCoordinator: EventEmitting {
    var eventPublisher: AnyPublisher<LoginNavigationCoordinatorEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
}

extension LoginNavigationCoordinator {
    func handleDeeplink(_ deeplink: Deeplink) {
        switch deeplink {
        case let .onboarding(page):
            let coordinator = makeOnboardingFlow(page: page)
            startChildCoordinator(coordinator)
            navigationController.present(coordinator.rootViewController, animated: true)
        default:
            break
        }
        childCoordinators.forEach { $0.handleDeeplink(deeplink) }
    }
    
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
}
