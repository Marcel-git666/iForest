//
//  AccessLevel.swift
//  iForest
//
//  Created by Marcel Mravec on 29.10.2024.
//

import Foundation

final class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var accessLevel: AccessLevel = .none

}

enum AccessLevel: CustomStringConvertible {
    case none
    case guest
    case authorized
    
    var description: String {
        switch self {
        case .none: return "None"
        case .guest: return "Guest"
        case .authorized: return "Authorized"
        }
    }
}
