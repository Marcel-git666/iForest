//
//  Stand.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import Foundation

struct Stand: Identifiable, Codable {
    var id: String
    var name: String
    var size: Double
    var shape: Shape
    var image: Data?
    var trees: [Tree]
    
    enum Shape: String, Codable {
        case circular
        case square
    }
}
