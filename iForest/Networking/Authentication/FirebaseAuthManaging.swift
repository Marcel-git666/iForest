//
//  FirebaseAuthManaging.swift
//  iForest
//
//  Created by Marcel Mravec on 14.09.2024.
//

import Foundation

protocol FirebaseAuthManaging {
    func signUp(_ credentials: Credentials) async throws
    func signIn(_ credentials: Credentials) async throws
    func signOut() async throws
}
