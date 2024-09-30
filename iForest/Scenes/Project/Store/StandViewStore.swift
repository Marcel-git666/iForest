//
//  StandsViewStore.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import Combine
import Foundation
import os
import SwiftUI

final class StandViewStore: ObservableObject {
    private let dataManager: DataManaging
    private let projectId: String
    private let logger = Logger()
    private let eventSubject = PassthroughSubject<StandViewEvent, Never>()
    
    @Published var state: StandsViewState = .loading
    @Published var stands: [Stand] = []
    
    var eventPublisher: AnyPublisher<StandViewEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    init(dataManager: DataManaging, projectId: String) {
        self.dataManager = dataManager
        self.projectId = projectId
        Task { @MainActor in
            send(.fetchStands)
        }
    }
    
    func sendEvent(_ event: StandViewEvent) {
        print("StandViewEvent: \(event)")
        eventSubject.send(event) // Safe way to expose sending events
    }
    
    @MainActor
    func send(_ action: StandsViewAction) {
        switch action {
        case .fetchStands:
            fetchStands()
        case let .createOrUpdateStand(stand):
            if let existingStand = stands.first(where: { $0.id == stand.id }) {
                updateStand(existingStand, with: stand)
            } else {
                createStand(stand)
            }
        case let .deleteStand(stand):
            deleteStand(stand)
        case let .openTrees(stand):
            eventSubject.send(.openTrees(stand))
        case let .capturePhoto(stand):
            eventSubject.send(.capturePhoto(stand))
        }
    }
    
    // Fetch stands for the current project
    @MainActor
    private func fetchStands() {
        state.status = .loading
        Task {
            do {
                let project = try await dataManager.fetchProjects().first { $0.id == projectId }
                if let project = project {
                    let fetchedStands = project.stands
                    DispatchQueue.main.async {
                        self.stands = fetchedStands
                        self.state.status = fetchedStands.isEmpty ? .empty : .loaded
                    }
                }
            } catch {
                logger.error("❌ Failed to fetch stands: \(error.localizedDescription)")
                self.state.status = .error
            }
        }
    }
    
    // Create a new stand
    @MainActor
    private func createStand(_ stand: Stand) {
        Task {
            do {
                let project = try await dataManager.fetchProjects().first { $0.id == projectId }
                if let project = project {
                    let newStand = try await dataManager.createStand(stand, for: project)
                    DispatchQueue.main.async {
                        self.stands.append(newStand)
                        self.state.status = .loaded
                    }
                }
            } catch {
                logger.error("❌ Failed to create stand: \(error.localizedDescription)")
            }
        }
    }
    
    // Delete a stand
    @MainActor
    private func deleteStand(_ stand: Stand) {
        Task {
            do {
                let project = try await dataManager.fetchProjects().first { $0.id == projectId }
                if let project = project {
                    try await dataManager.deleteStand(stand, from: project)
                    DispatchQueue.main.async {
                        self.stands.removeAll { $0.id == stand.id }
                        if self.stands.isEmpty {
                            self.state.status = .empty
                        }
                    }
                }
            } catch {
                logger.error("❌ Failed to delete stand: \(error.localizedDescription)")
            }
        }
    }
    
    // Update a stand
    @MainActor
    private func updateStand(_ existingStand: Stand, with updatedStand: Stand) {
        Task {
            do {
                // Fetch the project to ensure you're updating the stand within the correct project
                if let project = try await dataManager.fetchProjects().first(where: { $0.id == projectId }) {
                    // Update the stand in the correct project
                    try await dataManager.updateStand(updatedStand, in: project)
                    
                    // Update local state in the StandViewStore
                    DispatchQueue.main.async {
                        if let index = self.stands.firstIndex(where: { $0.id == existingStand.id }) {
                            self.stands[index] = updatedStand
                        }
                    }
                } else {
                    logger.error("❌ Project not found for ID: \(self.projectId)")
                }
            } catch {
                logger.error("❌ Failed to update stand: \(error.localizedDescription)")
            }
        }
    }
}
