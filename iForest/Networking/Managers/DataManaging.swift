//
//  FirestoreManaging.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import Foundation

protocol DataManaging {
    // Project-related operations
    func fetchProjects() async throws -> [Project]
    func createProject(_ project: Project) async throws -> Project
    func deleteProject(_ project: Project) async throws
    func updateProject(_ project: Project) async throws
    
    // Stand-related operations
    func fetchStands(for project: Project) async throws -> [Stand]
    func createStand(_ stand: Stand, for project: Project) async throws -> Stand
    func deleteStand(_ stand: Stand, from project: Project) async throws
    func updateStand(_ stand: Stand, in project: Project) async throws
    
    // Tree-related operations
    func fetchTrees(for stand: Stand) async throws -> [Tree]
    func createTree(_ tree: Tree, for stand: Stand) async throws -> Tree
    func deleteTree(_ tree: Tree, from stand: Stand) async throws
    func updateTree(_ tree: Tree, in stand: Stand) async throws
}
