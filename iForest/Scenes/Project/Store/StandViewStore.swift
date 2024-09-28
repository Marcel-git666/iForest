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
        case let .createStand(name, size, shape):
            createStand(name: name, size: size, shape: shape)
        case let .deleteStand(stand):
            deleteStand(stand)
        case .updateStand(let stand, let newName, let newSize, let newShape):
                updateStand(stand, newName: newName, newSize: newSize, newShape: newShape)
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
    private func createStand(name: String, size: Double, shape: Stand.Shape) {
        Task {
            do {
                let newStand = try await firestoreManager.createStand(for: projectId, name: name, size: size, shape: shape)
                DispatchQueue.main.async {
                    print("Stand created: \(newStand)") // Debugging
                    self.stands.append(newStand) // Append the new stand to the list
                    self.state.status = .loaded
                    self.sendEvent(.backToProject) // Navigate back to the stand list
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
    private func updateStand(_ stand: Stand, newName: String, newSize: Double, newShape: Stand.Shape) {
        Task {
            do {
                try await firestoreManager.updateStand(for: projectId, standId: stand.id, newName: newName, newSize: newSize, newShape: newShape)
                DispatchQueue.main.async {
                    if let index = self.stands.firstIndex(where: { $0.id == stand.id }) {
                        self.stands[index].name = newName
                        self.stands[index].size = newSize
                        self.stands[index].shape = newShape
                        print("Stand updated: \(self.stands[index])") // Debugging
                    }
                    self.sendEvent(.backToProject) // Navigate back to the stand list
                }
            } catch {
                logger.error("❌ Failed to update stand: \(error.localizedDescription)")
            }
        }
    }

}
