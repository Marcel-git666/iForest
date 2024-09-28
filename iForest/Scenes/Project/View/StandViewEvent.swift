//
//  StandsViewEvent.swift
//  iForest
//
//  Created by Marcel Mravec on 27.09.2024.
//

import Foundation

enum StandViewEvent {
    case createStandView
    case updateStandView(Stand)
    case backToProject
    case openTrees(Stand)
}
