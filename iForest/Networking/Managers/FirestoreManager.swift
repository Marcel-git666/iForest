//
//  FirestoreManager.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import FirebaseFirestore
import Foundation

final class FirestoreManager: FirestoreManaging {
    private let firestore = Firestore.firestore()

    func fetchProjects() async throws -> [Project] {
        let snapshot = try await firestore.collection("projects").getDocuments()
        return snapshot.documents.map { doc in
            let data = doc.data()
            return Project(id: doc.documentID, name: data["name"] as? String ?? "Unnamed Project")
        }
    }

    func createProject(name: String) async throws -> Project {
        let newProject = Project(id: UUID().uuidString, name: name)
        try await firestore.collection("projects").document(newProject.id).setData([
            "name": newProject.name
        ])
        return newProject
    }
}
