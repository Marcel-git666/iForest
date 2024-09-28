//
//  FirestoreManaging.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import Foundation

protocol DataManaging {
    func fetchProjects() async throws -> [Project]
    func createProject(name: String) async throws -> Project
    func deleteProject(_ projectId: String) async throws
    func updateProject(_ projectId: String, newName: String) async throws
    func fetchStands(for projectId: String) async throws -> [Stand]
    func createStand(for projectId: String, name: String, size: Double, shape: Stand.Shape) async throws -> Stand
    func deleteStand(for projectId: String, standId: String) async throws
    func updateStand(for projectId: String, standId: String, newName: String, newSize: Double, newShape: Stand.Shape) async throws
}
