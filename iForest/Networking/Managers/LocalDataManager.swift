//
//  LocalDataManager.swift
//  iForest
//
//  Created by Marcel Mravec on 26.09.2024.
//

import Foundation
import CoreData

final class LocalDataManager: DataManaging {
    private let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "iForestDataModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    // MARK: - Project Methods

    func fetchProjects() async throws -> [Project] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        let result = try context.fetch(fetchRequest)
        
        return result.compactMap { entity in
            guard let jsonData = entity.jsonData?.data(using: .utf8) else { return nil }
            return try? JSONDecoder().decode(Project.self, from: jsonData)
        }
    }

    func createProject(name: String) async throws -> Project {
        let context = persistentContainer.viewContext
        let newProject = Project(id: UUID().uuidString, name: name, stands: [])
        
        let entity = DataEntity(context: context)
        entity.id = newProject.id
        entity.jsonData = try String(data: JSONEncoder().encode(newProject), encoding: .utf8)
        
        try context.save()
        return newProject
    }

    func deleteProject(_ projectId: String) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", projectId)
        let result = try context.fetch(fetchRequest)
        if let entity = result.first {
            context.delete(entity)
            try context.save()
        }
    }

    func updateProject(_ projectId: String, newName: String) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", projectId)
        let result = try context.fetch(fetchRequest)
        if let entity = result.first,
           let jsonData = entity.jsonData?.data(using: .utf8), // Convert String to Data
           var project = try? JSONDecoder().decode(Project.self, from: jsonData) { // Decode the JSON
            project.name = newName
            entity.jsonData = try String(data: JSONEncoder().encode(project), encoding: .utf8) // Encode back to JSON string
            try context.save()
        }
    }

    // MARK: - Stand Methods

    func fetchStands(for projectId: String) async throws -> [Stand] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", projectId) // Fetch only the project with the given ID
        let result = try context.fetch(fetchRequest)
        
        // Check if the project with the given ID exists
        if let entity = result.first,
           let jsonData = entity.jsonData?.data(using: .utf8),
           let project = try? JSONDecoder().decode(Project.self, from: jsonData) {
            return project.stands // Return the stands for that specific project
        } else {
            return [] // Return an empty array if no project is found or decoding fails
        }
    }





    func createStand(for projectId: String, name: String, size: Double, shape: Stand.Shape) async throws -> Stand {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", projectId)
        let result = try context.fetch(fetchRequest)
        
        if let entity = result.first,
           let jsonData = entity.jsonData?.data(using: .utf8),
           var project = try? JSONDecoder().decode(Project.self, from: jsonData) {
            let newStand = Stand(id: UUID().uuidString, name: name, size: size, shape: shape, trees: [])
            project.stands.append(newStand)
            entity.jsonData = try String(data: JSONEncoder().encode(project), encoding: .utf8)
            try context.save()
            return newStand
        } else {
            throw NSError(domain: "ProjectNotFound", code: 404, userInfo: nil)
        }
    }

    func deleteStand(for projectId: String, standId: String) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", projectId)
        let result = try context.fetch(fetchRequest)
        
        if let entity = result.first,
           let jsonData = entity.jsonData?.data(using: .utf8),
           var project = try? JSONDecoder().decode(Project.self, from: jsonData) {
            project.stands.removeAll { $0.id == standId }
            entity.jsonData = try String(data: JSONEncoder().encode(project), encoding: .utf8)
            try context.save()
        }
    }

    func updateStand(for projectId: String, standId: String, newName: String, newSize: Double, newShape: Stand.Shape) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", projectId)
        let result = try context.fetch(fetchRequest)
        
        if let entity = result.first,
           let jsonData = entity.jsonData?.data(using: .utf8),
           var project = try? JSONDecoder().decode(Project.self, from: jsonData) {
            if let standIndex = project.stands.firstIndex(where: { $0.id == standId }) {
                project.stands[standIndex].name = newName
                project.stands[standIndex].size = newSize
                entity.jsonData = try String(data: JSONEncoder().encode(project), encoding: .utf8)
                try context.save()
            }
        }
    }
}
