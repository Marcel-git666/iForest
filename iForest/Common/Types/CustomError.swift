//
//  CustomError.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import Foundation

enum CustomError: Error {
    case networkError(message: String)
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
