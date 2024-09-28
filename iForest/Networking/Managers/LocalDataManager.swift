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
    
    // MARK: - Tree Methods
    
    func fetchTrees(for standId: String) async throws -> [Tree] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        
        // Fetch all projects, as Core Data doesn't support querying nested collections directly
        let result = try context.fetch(fetchRequest)
        
        // Find the project that contains the stand with the given standId
        for entity in result {
            if let jsonData = entity.jsonData?.data(using: .utf8),
               let project = try? JSONDecoder().decode(Project.self, from: jsonData) {
                
                // Find the correct stand by its id
                if let stand = project.stands.first(where: { $0.id == standId }) {
                    return stand.trees // Return the trees for the found stand
                }
            }
        }
        return [] // Return an empty array if no matching stand or trees are found
    }
    
    func createTree(for standId: String, name: String, size: Double, location: String) async throws -> Tree {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        let result = try context.fetch(fetchRequest)
        
        // Iterate over all projects to find the one containing the stand
        if let entity = result.first(where: { entity in
            if let jsonData = entity.jsonData?.data(using: .utf8),
               let project = try? JSONDecoder().decode(Project.self, from: jsonData),
               project.stands.contains(where: { $0.id == standId }) {
                return true
            }
            return false
        }) {
            if let jsonData = entity.jsonData?.data(using: .utf8),
               var project = try? JSONDecoder().decode(Project.self, from: jsonData),
               let standIndex = project.stands.firstIndex(where: { $0.id == standId }) {
                
                let newTree = Tree(id: UUID().uuidString, name: name, size: size, location: location, measurements: [])
                project.stands[standIndex].trees.append(newTree)
                entity.jsonData = try String(data: JSONEncoder().encode(project), encoding: .utf8)
                try context.save()
                return newTree
            }
        }
        throw NSError(domain: "StandNotFound", code: 404, userInfo: nil)
    }

    func deleteTree(for standId: String, treeId: String) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        let result = try context.fetch(fetchRequest)
        
        // Find the project containing the stand and tree
        if let entity = result.first(where: { entity in
            if let jsonData = entity.jsonData?.data(using: .utf8),
               let project = try? JSONDecoder().decode(Project.self, from: jsonData),
               project.stands.contains(where: { $0.id == standId }) {
                return true
            }
            return false
        }) {
            if let jsonData = entity.jsonData?.data(using: .utf8),
               var project = try? JSONDecoder().decode(Project.self, from: jsonData),
               let standIndex = project.stands.firstIndex(where: { $0.id == standId }) {
                
                project.stands[standIndex].trees.removeAll { $0.id == treeId }
                entity.jsonData = try String(data: JSONEncoder().encode(project), encoding: .utf8)
                try context.save()
            }
        }
    }
    
    func updateTree(for standId: String, treeId: String, newName: String, newSize: Double, newLocation: String) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        let result = try context.fetch(fetchRequest)
        
        // Find the project containing the stand and tree
        if let entity = result.first(where: { entity in
            if let jsonData = entity.jsonData?.data(using: .utf8),
               let project = try? JSONDecoder().decode(Project.self, from: jsonData),
               project.stands.contains(where: { $0.id == standId }) {
                return true
            }
            return false
        }) {
            if let jsonData = entity.jsonData?.data(using: .utf8),
               var project = try? JSONDecoder().decode(Project.self, from: jsonData),
               let standIndex = project.stands.firstIndex(where: { $0.id == standId }),
               let treeIndex = project.stands[standIndex].trees.firstIndex(where: { $0.id == treeId }) {
                
                project.stands[standIndex].trees[treeIndex].name = newName
                project.stands[standIndex].trees[treeIndex].size = newSize
                project.stands[standIndex].trees[treeIndex].location = newLocation
                entity.jsonData = try String(data: JSONEncoder().encode(project), encoding: .utf8)
                try context.save()
            }
        }
    }
}
