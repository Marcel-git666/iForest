//
//  TreeViewStore.swift
//  iForest
//
//  Created by Marcel Mravec on 28.09.2024.
//

import Combine
import Foundation
import os

final class TreeViewStore: ObservableObject {
    private let dataManager: DataManaging
    private let standId: String
    private let logger = Logger()
    private let eventSubject = PassthroughSubject<TreeViewEvent, Never>()
    
    @Published var state: TreeViewState = .loading
    @Published var trees: [Tree] = []
    
    var eventPublisher: AnyPublisher<TreeViewEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    init(dataManager: DataManaging, standId: String) {
        self.dataManager = dataManager
        self.standId = standId
        Task { @MainActor in
            send(.fetchTrees)
        }
    }
    
    func sendEvent(_ event: TreeViewEvent) {
        eventSubject.send(event)
    }
    
    @MainActor
    func send(_ action: TreeViewAction) {
        switch action {
        case .fetchTrees:
            fetchTrees()
        case let .createOrUpdateTree(tree):
            if let existingTree = trees.first(where: { $0.id == tree.id }) {
                updateTree(existingTree, with: tree)
            } else {
                createTree(tree)
            }
        case let .deleteTree(tree):
            deleteTree(tree)
        }
    }
    
    @MainActor
    private func fetchTrees() {
        Task {
            do {
                let project = try await dataManager.fetchProjects().first { $0.stands.contains(where: { $0.id == standId }) }
                if let stand = project?.stands.first(where: { $0.id == standId }) {
                    let fetchedTrees = stand.trees
                    DispatchQueue.main.async {
                        self.trees = fetchedTrees
                        self.state.status = fetchedTrees.isEmpty ? .empty : .loaded
                    }
                }
            } catch {
                logger.error("❌ Failed to fetch trees: \(error.localizedDescription)")
                self.state.status = .error
            }
        }
    }

    @MainActor
    private func createTree(_ tree: Tree) {
        Task {
            do {
                let project = try await dataManager.fetchProjects().first { $0.stands.contains(where: { $0.id == standId }) }
                if let stand = project?.stands.first(where: { $0.id == standId }) {
                    let newTree = try await dataManager.createTree(tree, for: stand)
                    DispatchQueue.main.async {
                        self.trees.append(newTree)
                        self.state.status = .loaded
                        self.sendEvent(.backToStand)
                    }
                }
            } catch {
                logger.error("❌ Failed to create tree: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    private func updateTree(_ existingTree: Tree, with updatedTree: Tree) {
        Task {
            do {
                let project = try await dataManager.fetchProjects().first { $0.stands.contains(where: { $0.id == standId }) }
                if let stand = project?.stands.first(where: { $0.id == standId }) {
                    try await dataManager.updateTree(updatedTree, in: stand)
                    DispatchQueue.main.async {
                        if let index = self.trees.firstIndex(where: { $0.id == existingTree.id }) {
                            self.trees[index] = updatedTree
                            self.sendEvent(.backToStand)
                        }
                    }
                }
            } catch {
                logger.error("❌ Failed to update tree: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    private func deleteTree(_ tree: Tree) {
        Task {
            do {
                let project = try await dataManager.fetchProjects().first { $0.stands.contains(where: { $0.id == standId }) }
                if let stand = project?.stands.first(where: { $0.id == standId }) {
                    try await dataManager.deleteTree(tree, from: stand)
                    DispatchQueue.main.async {
                        self.trees.removeAll { $0.id == tree.id }
                        if self.trees.isEmpty {
                            self.state.status = .empty
                        }
                    }
                }
            } catch {
                logger.error("❌ Failed to delete tree: \(error.localizedDescription)")
            }
        }
    }
}
