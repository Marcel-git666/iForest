//
//  ProjectViewState.swift
//  iForest
//
//  Created by Marcel Mravec on 06.09.2024.
//

import Foundation

struct ProjectViewState {
    enum Status {
        case initial
        case loaded
        case loading
        case error
        case empty
    }
    
    var status: Status = .initial

    static let initial = ProjectViewState()
}
