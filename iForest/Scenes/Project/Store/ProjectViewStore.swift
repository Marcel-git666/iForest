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
        case .logout:
            eventSubject.send(.logout)
        case .createProject(let name):
            createProject(name: name)
        case .openCreateProjectView:
            eventSubject.send(.openCreateProjectView)
        }
    }
    
    @MainActor
    func fetchProjects() {
        Task {
            do {
                let fetchedProjects = try await firestoreManager.fetchProjects()
                DispatchQueue.main.async {
                    self.projects = fetchedProjects
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
                    self.logger.info("✅ Project created: \(newProject.name)")
                }
            } catch {
                logger.error("❌ Failed to create project: \(error.localizedDescription)")
            }
        }
    }
    //    func loadProjects() {
    //        // Later replace with Firestore fetching logic
    //        // Currently, using mock data
    //        projects = [
    //            Project(id: UUID().uuidString, name: "Project A"),
    //            Project(id: UUID().uuidString, name: "Project B")
    //        ]
    //    }
    //
    //    func createNewProject(name: String) {
    //        let newProject = Project(id: UUID().uuidString, name: name)
    //        projects.append(newProject)
    //        logger.info("✅ New project created: \(newProject.name)")
    //    }
    
}
