//
//  KeychainManagerError.swift
//  iForest
//
//  Created by Marcel Mravec on 14.09.2024.
//

import Foundation

enum KeychainManagerError: Error {
    case encodingError(Error)
    case decodingError(Error)
    case dataNotFound
    case removeFailure(Error?)
}
