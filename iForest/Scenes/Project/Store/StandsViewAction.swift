//
//  StandsViewAction.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import Foundation

enum StandsViewAction {
    case fetchStands
    case createOrUpdateStand(stand: Stand)
    case deleteStand(Stand)
    case openTrees(Stand)
}
