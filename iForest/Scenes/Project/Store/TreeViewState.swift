//
//  TreeViewState.swift
//  iForest
//
//  Created by Marcel Mravec on 28.09.2024.
//

import Foundation

struct TreeViewState {
    enum Status {
        case loading
        case loaded
        case empty
        case error
    }
    
    var status: Status = .loading
    
    static let loading = TreeViewState()
}
