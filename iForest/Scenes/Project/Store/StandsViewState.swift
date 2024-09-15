//
//  StandsViewState.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import Foundation

struct StandsViewState {
    enum Status {
        case loading
        case loaded
        case empty
        case error
    }

    var status: Status = .loading
    
    static let loading = StandsViewState()
}
