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
//    private let keychainService: KeychainServicing
//    private let authManager: FirebaseAuthManaging
    private let logger = Logger()
    private let eventSubject = PassthroughSubject<ProjectViewEvent, Never>()
    @Published var state: ProjectViewState = .initial
    var eventPublisher: AnyPublisher<ProjectViewEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
//    init(keychainService: KeychainServicing, authManager: FirebaseAuthManaging) {
//        self.keychainService = keychainService
//        self.authManager = authManager
//    }
}

extension ProjectViewStore {
    @MainActor
    func send(_ action: ProjectViewAction) {
        switch action {
        
        }
    }
}
