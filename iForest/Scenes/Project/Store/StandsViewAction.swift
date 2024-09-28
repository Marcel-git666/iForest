//
//  StandsViewAction.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import Foundation

enum StandsViewAction {
    case fetchStands
    case createStand(name: String, size: Double, shape: Stand.Shape)
    case deleteStand(Stand)
    case updateStand(Stand, newName: String, newSize: Double, newShape: Stand.Shape)
}
