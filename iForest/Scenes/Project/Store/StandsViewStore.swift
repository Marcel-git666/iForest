//
//  StandsViewStore.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import Combine
import Foundation
import os

final class StandsViewStore: ObservableObject {
    private let firestoreManager: FirestoreManaging
    private let projectId: String
    private let logger = Logger()

    @Published var state: StandsViewState = .loading
    @Published var stands: [Stand] = []

    init(firestoreManager: FirestoreManaging, projectId: String) {
        self.firestoreManager = firestoreManager
        self.projectId = projectId
        Task { @MainActor in
            send(.fetchStands)
        }
    }

    // Handle actions
    @MainActor
    func send(_ action: StandsViewAction) {
        switch action {
        case .fetchStands:
            fetchStands()

        case let .createStand(name, size):
            createStand(name: name, size: size)

        case let .deleteStand(stand):
            deleteStand(stand)

        case let .updateStand(stand, newName, newSize):
            updateStand(stand, newName: newName, newSize: newSize)
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
    private func createStand(name: String, size: Double) {
        Task {
            do {
                let newStand = try await firestoreManager.createStand(for: projectId, name: name, size: size)
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
    private func updateStand(_ stand: Stand, newName: String, newSize: Double) {
        Task {
            do {
                try await firestoreManager.updateStand(for: projectId, standId: stand.id, newName: newName, newSize: newSize)
                DispatchQueue.main.async {
                    if let index = self.stands.firstIndex(where: { $0.id == stand.id }) {
                        self.stands[index].name = newName
                        self.stands[index].size = newSize
                    }
                }
            } catch {
                logger.error("❌ Failed to update stand: \(error.localizedDescription)")
            }
        }
    }
}
