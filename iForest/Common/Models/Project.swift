//
//  Project.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import Foundation

struct Project: Codable, Identifiable {
    let id: String
    var name: String
    var stands: [Stand]
}
