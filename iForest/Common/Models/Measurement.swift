//
//  Measurement.swift
//  iForest
//
//  Created by Marcel Mravec on 26.09.2024.
//

import Foundation

struct Measurement: Identifiable, Codable {
    var id: String
    var date: Date
    var height: Double
    var girth: Double
    var photo: Data?
}
