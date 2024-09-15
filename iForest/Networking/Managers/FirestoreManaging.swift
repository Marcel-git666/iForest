//
//  FirestoreManaging.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import Foundation

protocol FirestoreManaging {
    func fetchProjects() async throws -> [Project]
    func createProject(name: String) async throws -> Project
}
