//
//  Tree.swift
//  iForest
//
//  Created by Marcel Mravec on 26.09.2024.
//

import Foundation

struct Tree: Identifiable, Codable {
    var id: String
    var name: String
    var location: String
    var measurements: [Measurement]
}
