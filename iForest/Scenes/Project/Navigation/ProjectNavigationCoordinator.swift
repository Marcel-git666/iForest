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
        let store = StandViewStore(firestoreManager: LocalDataManager(), projectId: project.id)
        
        // Listen for StandsViewEvent from StandsViewStore
        store.eventPublisher
            .sink { [weak self] event in
                self?.handleStandsEvent(event)
            }
            .store(in: &cancellables)
        
        let standsView = StandView(store: store)
        let viewController = UIHostingController(rootView: standsView)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func handleStandsEvent(_ event: StandViewEvent) {
        print("Handling StandViewEvent: \(event)")
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
        print("presentCreateStandView called") // Debugging output
        
        // Iterate through the view controllers in the stack and find StandView
        if let standViewController = navigationController.viewControllers.first(where: { $0 is UIHostingController<StandView> }) as? UIHostingController<StandView> {
            let store = standViewController.rootView.store // Access the store from StandView

            // Create the StandCreationView with the store
            let creationView = StandCreationView(store: store)

            let viewController = UIHostingController(rootView: creationView)
            print("Pushing StandCreationView to navigation stack") // Add this for debugging

            // Push the new view controller onto the navigation stack
            navigationController.pushViewController(viewController, animated: true)
        } else {
            print("Error: Could not find StandView in the navigation stack") // Add this for debugging
        }
    }
    
    private func presentUpdateStandView(for stand: Stand) {
        print("presentUpdateStandView called for stand: \(stand)") // Debugging output
        
        // Iterate through the view controllers in the stack and find StandView
        if let standViewController = navigationController.viewControllers.first(where: { $0 is UIHostingController<StandView> }) as? UIHostingController<StandView> {
            let store = standViewController.rootView.store // Access the store from StandView

            // Create the StandCreationView for updating
            let updateView = StandCreationView(store: store, stand: stand)

            // Push the update view onto the navigation stack
            let viewController = UIHostingController(rootView: updateView)
            print("Pushing StandCreationView for update to navigation stack") // Debugging
            navigationController.pushViewController(viewController, animated: true)
        } else {
            print("Error: Could not find StandView in the navigation stack") // Add this for debugging
        }
    }
}

extension ProjectNavigationCoordinator: EventEmitting {
    var eventPublisher: AnyPublisher<ProjectNavigationCoordinatorEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
}
