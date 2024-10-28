//
//  ProjectViewAction.swift
//  iForest
//
//  Created by Marcel Mravec on 06.09.2024.
//

import Foundation

enum ProjectViewAction {
    case openCreateProjectView
    case openStands(Project)
    case deleteProject(Project)
    case createProject(String)
    case logout
    case login
}

