//
//  ProjectViewStore.swift
//  iForest
//
//  Created by Marcel Mravec on 06.09.2024.
//

import Foundation

import Combine
import os

final class ProjectViewStore: ObservableObject, Store {
    private let firestoreManager: FirestoreManaging
    private let logger = Logger()
    private let eventSubject = PassthroughSubject<ProjectViewEvent, Never>()
    @Published var state: ProjectViewState = .initial
    @Published var projects: [Project] = []
    
    var eventPublisher: AnyPublisher<ProjectViewEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    init(firestoreManager: FirestoreManaging) {
        self.firestoreManager = firestoreManager
        Task { @MainActor in
            fetchProjects()
        }
    }
}

extension ProjectViewStore {
    @MainActor
    func send(_ action: ProjectViewAction) {
        switch action {
        case .openCreateProjectView:
            eventSubject.send(.openCreateProjectView)
        case let .openStands(project):
            eventSubject.send(.openStands(project))
        case let .deleteProject(project):
            deleteProject(project)
        case let .createProject(projectName):  // Handle the createProject action
            createProject(name: projectName)
        case .logout:
            eventSubject.send(.logout)
        }
    }
    
    @MainActor
    func fetchProjects() {
        Task {
            do {
                let fetchedProjects = try await firestoreManager.fetchProjects()
                DispatchQueue.main.async {
                    if fetchedProjects.isEmpty {
                        self.state.status = .empty // Update to empty state if no projects
                    } else {
                        self.projects = fetchedProjects
                        self.state.status = .initial // Back to initial once data is loaded
                    }
                }
            } catch {
                logger.error("❌ Failed to fetch projects: \(error.localizedDescription)")
            }
        }
    }
    
    // Create a project using FirestoreManager
    @MainActor
    func createProject(name: String) {
        Task {
            do {
                let newProject = try await firestoreManager.createProject(name: name)
                DispatchQueue.main.async {
                    self.projects.append(newProject)
                    self.state.status = .initial
                    self.logger.info("✅ Project created: \(newProject.name)")
                }
            } catch {
                logger.error("❌ Failed to create project: \(error.localizedDescription)")
            }
        }
    }
    @MainActor
    func deleteProject(_ project: Project) {
        Task {
            do {
                try await firestoreManager.deleteProject(project.id)
                DispatchQueue.main.async {
                    self.projects.removeAll { $0.id == project.id }
                    if self.projects.isEmpty {
                        self.state.status = .empty
                    }
                    self.logger.info("🗑️ Project deleted: \(project.name)")
                }
            } catch {
                logger.error("❌ Failed to delete project: \(error.localizedDescription)")
            }
        }
    }
    
    // Update a project name
    @MainActor
    func updateProject(_ project: Project, newName: String) {
        Task {
            do {
                try await firestoreManager.updateProject(project.id, newName: newName)
                DispatchQueue.main.async {
                    if let index = self.projects.firstIndex(where: { $0.id == project.id }) {
                        self.projects[index].name = newName
                        self.logger.info("✏️ Project updated: \(newName)")
                    }
                }
            } catch {
                logger.error("❌ Failed to update project: \(error.localizedDescription)")
            }
        }
    }
}
