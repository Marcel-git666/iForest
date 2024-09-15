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
    
    func deleteProject(_ projectId: String) async throws {
        try await firestore.collection("projects").document(projectId).delete()
    }
    
    func updateProject(_ projectId: String, newName: String) async throws {
        try await firestore.collection("projects").document(projectId).updateData([
            "name": newName
        ])
    }
    
    // Fetch Stands for a specific project
       func fetchStands(for projectId: String) async throws -> [Stand] {
           let snapshot = try await firestore.collection("projects").document(projectId).collection("stands").getDocuments()
           return snapshot.documents.map { doc in
               let data = doc.data()
               return Stand(id: doc.documentID, name: data["name"] as? String ?? "Unnamed Stand", size: data["size"] as? Double ?? 0.0)
           }
       }

       // Create a new Stand within a project
       func createStand(for projectId: String, name: String, size: Double) async throws -> Stand {
           let newStand = Stand(id: UUID().uuidString, name: name, size: size)
           try await firestore.collection("projects").document(projectId).collection("stands").document(newStand.id).setData([
               "name": newStand.name,
               "size": newStand.size
           ])
           return newStand
       }

       // Delete a Stand within a project
       func deleteStand(for projectId: String, standId: String) async throws {
           try await firestore.collection("projects").document(projectId).collection("stands").document(standId).delete()
       }

       // Update a Stand's name and size within a project
       func updateStand(for projectId: String, standId: String, newName: String, newSize: Double) async throws {
           try await firestore.collection("projects").document(projectId).collection("stands").document(standId).updateData([
               "name": newName,
               "size": newSize
           ])
       }
}
