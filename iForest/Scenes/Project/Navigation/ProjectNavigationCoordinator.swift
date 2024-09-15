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
    
    // MARK: Lifecycle
    deinit {
        logger.info("❌ Deinit ProjectNavigationCoordinator")
    }
    
    func start() {
        navigationController.setViewControllers([makeProject()], animated: true)
    }
}

// MARK: - Factories
private extension ProjectNavigationCoordinator {
    func makeProject() -> UIViewController {
        let store = ProjectViewStore()
        store.eventPublisher
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
            .store(in: &cancellables)
        return UIHostingController(rootView: ProjectView(store: store))
    }
}

private extension ProjectNavigationCoordinator {
    func handleEvent(_ event: ProjectViewEvent) {
        switch event {
        case .logout:
            eventSubject.send(.logout(self))
        case .openCreateProjectView:
            presentCreateProjectView()
        }
    }
    
    private func presentCreateProjectView() {
        let creationView = ProjectCreationView { [weak self] projectName in
            self?.navigationController.popViewController(animated: true)
            self?.store.send(.createProject(projectName)) // Dispatch action to create project
        }
        let viewController = UIHostingController(rootView: creationView)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension ProjectNavigationCoordinator: EventEmitting {
    var eventPublisher: AnyPublisher<ProjectNavigationCoordinatorEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
}
