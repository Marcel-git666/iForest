//
//  ProjectViewEvent.swift
//  iForest
//
//  Created by Marcel Mravec on 06.09.2024.
//

import Foundation

enum ProjectViewEvent {
    case logout
    case openCreateProjectView
    case openStands(Project)
    case backToProjectList
    case login
}
