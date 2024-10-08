//
//  LoginViewState.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import Foundation

struct LoginViewState {
    enum Status {
        case initial
        case loggedIn
        case loggedOut
    }
    
    var email: String
    var password: String
    var rememberMe: Bool
    
    var status: Status = .initial

    static let initial = LoginViewState(email: "", password: "", rememberMe: false)
}
