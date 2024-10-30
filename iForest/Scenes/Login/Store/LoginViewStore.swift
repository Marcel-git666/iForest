//
//  LoginViewStore.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import Combine
import os

final class LoginViewStore: ObservableObject, Store {
    private let keychainService: KeychainServicing
    private let authManager: FirebaseAuthManaging
    private let logger = Logger()
    private let eventSubject = PassthroughSubject<LoginViewEvent, Never>()
    @Published var state: LoginViewState = .initial
    var eventPublisher: AnyPublisher<LoginViewEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    init(keychainService: KeychainServicing, authManager: FirebaseAuthManaging) {
        self.keychainService = keychainService
        self.authManager = authManager
    }
}

extension LoginViewStore {
    @MainActor
    func send(_ action: LoginViewAction) {
        switch action {
        case .viewDidLoad:
            checkLoginState()
        case .removeLogin:
            logout()
        case let .storeLogin(email):
            storeLogin(email)
        case .skipLogin:
            logger.info("I'm in switch trying to skipLogin.\n")
            skipLogin()
        }
    }
    @MainActor
    private func checkLoginState() {
        // Set `status` based on Keychain data presence
        if let _ = try? keychainService.fetchAuthData() {
            state.status = .loggedIn
        } else {
            state.status = .loggedOut
        }
    }
}

extension LoginViewStore {
    @MainActor
    func storeLogin(_ email: String) {
        do {
            try keychainService.storeLogin(email)
            state.status = .loggedIn
        } catch {
            logger.info("❌ Login (email) not saved due to exception.")
        }
    }
    @MainActor
    private func logout() {
        removeLogin()
        state.status = .loggedOut // Update state to loggedOut on logout
        eventSubject.send(.loggedOut)
    }
    
    func removeLogin() {
        do {
            try keychainService.removeLoginData()
        } catch {
            logger.info("❌ Login (email) not removed due to exception.")
        }
    }
    
    @MainActor
    func fetchLogin() {
        do {
            let loginString = try keychainService.fetchLogin()
            state.email = loginString
            state.rememberMe = true
        } catch {
            logger.info("❌ Credentials are not fetched.")
        }
    }
}

extension LoginViewStore {
    @MainActor
    func signIn() {
        Task {
            do {
                try await authManager.signIn(Credentials(email: state.email, password: state.password))
                eventSubject.send(.loggedIn)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func signUp() {
        Task {
            do {
                try await authManager.signUp(Credentials(email: state.email, password: state.password))
                DispatchQueue.main.async {
                    self.eventSubject.send(.loggedIn)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    @MainActor
    private func skipLogin() {
        logger.info("I'm in skipLogin function.\n")
        state.status = .loggedOut
        eventSubject.send(.loggedOut)
    }
}
