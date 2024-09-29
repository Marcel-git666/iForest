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
    
    func createProject(_ project: Project) async throws -> Project {
        let context = persistentContainer.viewContext
        
        let entity = DataEntity(context: context)
        entity.id = project.id
        entity.jsonData = try String(data: JSONEncoder().encode(project), encoding: .utf8)
        
        try context.save()
        return project
    }
    
    func deleteProject(_ project: Project) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", project.id)
        let result = try context.fetch(fetchRequest)
        if let entity = result.first {
            context.delete(entity)
            try context.save()
        }
    }
    
    func updateProject(_ project: Project) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", project.id)
        let result = try context.fetch(fetchRequest)
        if let entity = result.first {
            entity.jsonData = try String(data: JSONEncoder().encode(project), encoding: .utf8)
            try context.save()
        }
    }
    
    // MARK: - Stand Methods
    
    func fetchStands(for project: Project) async throws -> [Stand] {
        return project.stands
    }
    
    func createStand(_ stand: Stand, for project: Project) async throws -> Stand {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", project.id)
        let result = try context.fetch(fetchRequest)
        
        if let entity = result.first,
           var existingProject = try? JSONDecoder().decode(Project.self, from: entity.jsonData?.data(using: .utf8) ?? Data()) {
            
            existingProject.stands.append(stand)
            entity.jsonData = try String(data: JSONEncoder().encode(existingProject), encoding: .utf8)
            try context.save()
            return stand
        } else {
            throw NSError(domain: "ProjectNotFound", code: 404, userInfo: nil)
        }
    }
    
    func deleteStand(_ stand: Stand, from project: Project) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", project.id)
        let result = try context.fetch(fetchRequest)
        
        if let entity = result.first,
           var existingProject = try? JSONDecoder().decode(Project.self, from: entity.jsonData?.data(using: .utf8) ?? Data()) {
            
            existingProject.stands.removeAll { $0.id == stand.id }
            entity.jsonData = try String(data: JSONEncoder().encode(existingProject), encoding: .utf8)
            try context.save()
        }
    }
    
    func updateStand(_ stand: Stand, in project: Project) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", project.id)
        let result = try context.fetch(fetchRequest)
        
        if let entity = result.first,
           var existingProject = try? JSONDecoder().decode(Project.self, from: entity.jsonData?.data(using: .utf8) ?? Data()) {
            
            if let index = existingProject.stands.firstIndex(where: { $0.id == stand.id }) {
                existingProject.stands[index] = stand
                entity.jsonData = try String(data: JSONEncoder().encode(existingProject), encoding: .utf8)
                try context.save()
            }
        }
    }
    
    // MARK: - Tree Methods
    
    func fetchTrees(for stand: Stand) async throws -> [Tree] {
        return stand.trees
    }
    
    func createTree(_ tree: Tree, for stand: Stand) async throws -> Tree {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        
        // Iterate over all projects to find the one containing the stand
        let result = try context.fetch(fetchRequest)
        if let entity = result.first(where: { entity in
            if let jsonData = entity.jsonData?.data(using: .utf8),
               let project = try? JSONDecoder().decode(Project.self, from: jsonData),
               project.stands.contains(where: { $0.id == stand.id }) {
                return true
            }
            return false
        }) {
            if let jsonData = entity.jsonData?.data(using: .utf8),
               var project = try? JSONDecoder().decode(Project.self, from: jsonData),
               let standIndex = project.stands.firstIndex(where: { $0.id == stand.id }) {
                
                project.stands[standIndex].trees.append(tree)
                entity.jsonData = try String(data: JSONEncoder().encode(project), encoding: .utf8)
                try context.save()
                return tree
            }
        }
        throw NSError(domain: "StandNotFound", code: 404, userInfo: nil)
    }
    
    func deleteTree(_ tree: Tree, from stand: Stand) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        
        // Iterate over all projects to find the one containing the stand
        let result = try context.fetch(fetchRequest)
        if let entity = result.first(where: { entity in
            if let jsonData = entity.jsonData?.data(using: .utf8),
               let project = try? JSONDecoder().decode(Project.self, from: jsonData),
               project.stands.contains(where: { $0.id == stand.id }) {
                return true
            }
            return false
        }) {
            if let jsonData = entity.jsonData?.data(using: .utf8),
               var project = try? JSONDecoder().decode(Project.self, from: jsonData),
               let standIndex = project.stands.firstIndex(where: { $0.id == stand.id }) {
                
                project.stands[standIndex].trees.removeAll { $0.id == tree.id }
                entity.jsonData = try String(data: JSONEncoder().encode(project), encoding: .utf8)
                try context.save()
            }
        }
    }
    
    func updateTree(_ tree: Tree, in stand: Stand) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DataEntity> = DataEntity.fetchRequest()
        
        // Iterate over all projects to find the one containing the stand
        let result = try context.fetch(fetchRequest)
        if let entity = result.first(where: { entity in
            if let jsonData = entity.jsonData?.data(using: .utf8),
               let project = try? JSONDecoder().decode(Project.self, from: jsonData),
               project.stands.contains(where: { $0.id == stand.id }) {
                return true
            }
            return false
        }) {
            if let jsonData = entity.jsonData?.data(using: .utf8),
               var project = try? JSONDecoder().decode(Project.self, from: jsonData),
               let standIndex = project.stands.firstIndex(where: { $0.id == stand.id }),
               let treeIndex = project.stands[standIndex].trees.firstIndex(where: { $0.id == tree.id }) {
                
                project.stands[standIndex].trees[treeIndex] = tree
                entity.jsonData = try String(data: JSONEncoder().encode(project), encoding: .utf8)
                try context.save()
            }
        }
    }
}
