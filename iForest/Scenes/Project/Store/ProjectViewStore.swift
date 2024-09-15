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
    private let logger = Logger()
    private let eventSubject = PassthroughSubject<ProjectViewEvent, Never>()
    @Published var state: ProjectViewState = .initial
    @Published var projects: [Project] = []
    
    var eventPublisher: AnyPublisher<ProjectViewEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    init() {
        loadProjects()
    }
    
}

extension ProjectViewStore {
    @MainActor
    func send(_ action: ProjectViewAction) {
        switch action {
        case .logout:
            eventSubject.send(.logout)
        case .createProject(let name):
            createNewProject(name: name)
        case .openCreateProjectView:
            eventSubject.send(.openCreateProjectView)
        }
    }
    
    func loadProjects() {
        // Later replace with Firestore fetching logic
        // Currently, using mock data
        projects = [
            Project(id: UUID().uuidString, name: "Project A"),
            Project(id: UUID().uuidString, name: "Project B")
        ]
    }
    
    func createNewProject(name: String) {
        let newProject = Project(id: UUID().uuidString, name: name)
        projects.append(newProject)
        logger.info("✅ New project created: \(newProject.name)")
    }
    
}
