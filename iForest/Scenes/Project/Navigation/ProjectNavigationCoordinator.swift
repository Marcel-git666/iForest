//
//  ProjectNavigationCoordinator.swift
//  iForest
//
//  Created by Marcel Mravec on 06.09.2024.
//

import Combine
import os
import SwiftUI
import UIKit

protocol ProjectCoordinating: NavigationControllerCoordinator {}

final class ProjectNavigationCoordinator: NSObject, ProjectCoordinating {
    private(set) var navigationController: UINavigationController = CustomNavigationController()
    private lazy var cancellables = Set<AnyCancellable>()
    private let eventSubject = PassthroughSubject<ProjectNavigationCoordinatorEvent, Never>()
    private let logger = Logger()
    var childCoordinators = [Coordinator]()
    private var projectViewStore: ProjectViewStore?
    
    // MARK: Lifecycle
    deinit {
        logger.info("❌ Deinit ProjectNavigationCoordinator")
    }
    
    func start() {
        let firestoreManager = FirestoreManager()
        let store = ProjectViewStore(firestoreManager: firestoreManager)
        self.projectViewStore = store // Store reference to use later
        
        store.eventPublisher
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
            .store(in: &cancellables)
        
        navigationController.setViewControllers([makeProject(with: store)], animated: true)
    }
}

// MARK: - Factories
private extension ProjectNavigationCoordinator {
    func makeProject(with store: ProjectViewStore) -> UIViewController {
        return UIHostingController(rootView: ProjectView(store: store))
    }
}

private extension ProjectNavigationCoordinator {
    func handleEvent(_ event: ProjectViewEvent) {
        switch event {
        case .logout:
            eventSubject.send(.logout(self))
        case .openCreateProjectView:
            if navigationController.viewControllers.first is UIHostingController<ProjectView> {
                presentCreateProjectView()
            }
        }
    }
    
    func presentCreateProjectView() {
        let creationView = ProjectCreationView { [weak self] projectName in
            self?.navigationController.popViewController(animated: true) // Go back after saving
            if let projectViewController = self?.navigationController.viewControllers.first as? UIHostingController<ProjectView> {
                Task { @MainActor in
                    projectViewController.rootView.store.send(.createProject(projectName)) // Ensure this runs on the main actor
                }
            }
        }
        let viewController = UIHostingController(rootView: creationView)
        navigationController.pushViewController(viewController, animated: true) // Push the new view
    }
}

extension ProjectNavigationCoordinator: EventEmitting {
    var eventPublisher: AnyPublisher<ProjectNavigationCoordinatorEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
}
