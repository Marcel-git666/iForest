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
        let firestoreManager = LocalDataManager()
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
    private func handleEvent(_ event: ProjectViewEvent) {
        switch event {
        case .logout:
            eventSubject.send(.logout(self))
            
        case .openCreateProjectView:
            presentCreateProjectView()
            
        case let .openStands(project):
            presentStandsView(for: project) // Navigate to StandsView when a project is tapped
        }
    }
    
    
    func presentCreateProjectView() {
        let creationView = ProjectCreationView { [weak self] projectName in
            self?.navigationController.popViewController(animated: true) // Go back after saving
            if let projectViewController = self?.navigationController.viewControllers.first as? UIHostingController<ProjectView> {
                Task { @MainActor in
                    projectViewController.rootView.store.send(.createProject(projectName)) // Add the project
                }
            }
        }
        let viewController = UIHostingController(rootView: creationView)
        navigationController.pushViewController(viewController, animated: true) // Push the new view
    }
    
    private func presentStandsView(for project: Project) {
        let store = StandsViewStore(firestoreManager: LocalDataManager(), projectId: project.id)
        
        // Listen for StandsViewEvent from StandsViewStore
        store.eventPublisher
            .sink { [weak self] event in
                self?.handleStandsEvent(event)
            }
            .store(in: &cancellables)
        
        let standsView = StandsView(store: store)
        let viewController = UIHostingController(rootView: standsView)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func handleStandsEvent(_ event: StandsViewEvent) {
        switch event {
        case .createStandView:
            presentCreateStandView() // Present the creation view when event is triggered
        case .updateStandView(let stand):
            presentUpdateStandView(for: stand) // Handle update
        case .backToProject:
            navigationController.popViewController(animated: true) // Navigate back to the project view
        }
    }
    
    private func presentCreateStandView() {
        let creationView = StandCreationView { [weak self] standName, standSize in
            self?.navigationController.popViewController(animated: true) // Go back after saving
            if let standsViewController = self?.navigationController.viewControllers.first as? UIHostingController<StandsView> {
                Task { @MainActor in
                    standsViewController.rootView.store.send(.createStand(name: standName, size: standSize)) // Add the stand
                }
            }
        }
        let viewController = UIHostingController(rootView: creationView)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func presentUpdateStandView(for stand: Stand) {
        let updateView = StandCreationView(stand: stand) { [weak self] updatedName, updatedSize in
            self?.navigationController.popViewController(animated: true) // Go back after saving
            if let standsViewController = self?.navigationController.viewControllers.first as? UIHostingController<StandsView> {
                Task { @MainActor in
                    standsViewController.rootView.store.send(.updateStand(stand, newName: updatedName, newSize: updatedSize)) // Update the stand
                }
            }
        }
        let viewController = UIHostingController(rootView: updateView)
        navigationController.pushViewController(viewController, animated: true)
    }
    
}

extension ProjectNavigationCoordinator: EventEmitting {
    var eventPublisher: AnyPublisher<ProjectNavigationCoordinatorEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
}
