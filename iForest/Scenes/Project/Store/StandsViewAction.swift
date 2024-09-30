//
//  StandsViewAction.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import SwiftUI

enum StandsViewAction {
    case fetchStands
    case createOrUpdateStand(stand: Stand)
    case deleteStand(Stand)
    case openTrees(Stand)
    case capturePhoto(Stand)
    case photoCaptured(image: UIImage)
}
