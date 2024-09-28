//
//  StandsViewStore.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import Combine
import Foundation
import os

final class StandViewStore: ObservableObject {
    private let firestoreManager: DataManaging
    private let projectId: String
    private let logger = Logger()
    private let eventSubject = PassthroughSubject<StandViewEvent, Never>()
    
    @Published var state: StandsViewState = .loading
    @Published var stands: [Stand] = []
    
    var eventPublisher: AnyPublisher<StandViewEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    init(firestoreManager: DataManaging, projectId: String) {
        self.firestoreManager = firestoreManager
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
        }
    }
    
    // Fetch stands for the current project
    @MainActor
    private func fetchStands() {
        state.status = .loading
        Task {
            do {
                let fetchedStands = try await firestoreManager.fetchStands(for: projectId)
                DispatchQueue.main.async {
                    self.stands = fetchedStands
                    self.state.status = fetchedStands.isEmpty ? .empty : .loaded
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
                let newStand = try await firestoreManager.createStand(for: projectId, name: stand.name, size: stand.size, shape: stand.shape)
                DispatchQueue.main.async {
                    self.stands.append(newStand)
                    self.state.status = .loaded
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
                try await firestoreManager.deleteStand(for: projectId, standId: stand.id)
                DispatchQueue.main.async {
                    self.stands.removeAll { $0.id == stand.id }
                    if self.stands.isEmpty {
                        self.state.status = .empty
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
                try await firestoreManager.updateStand(for: projectId, standId: updatedStand.id, newName: updatedStand.name, newSize: updatedStand.size, newShape: updatedStand.shape)
                DispatchQueue.main.async {
                    if let index = self.stands.firstIndex(where: { $0.id == existingStand.id }) {
                        self.stands[index] = updatedStand
                    }
                }
            } catch {
                logger.error("❌ Failed to update stand: \(error.localizedDescription)")
            }
        }
    }
}
