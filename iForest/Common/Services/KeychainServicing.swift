//
//  KeychainServicing.swift
//  iForest
//
//  Created by Marcel Mravec on 14.09.2024.
//

import Foundation

protocol KeychainServicing {
    var keychainManager: KeychainManaging { get }

    func storeAuthData(authData: String) throws
    func fetchAuthData() throws -> String
    func removeAuthData() throws
    func storeLogin(_ login: String) throws
    func fetchLogin() throws -> String
    func removeLoginData() throws
}
