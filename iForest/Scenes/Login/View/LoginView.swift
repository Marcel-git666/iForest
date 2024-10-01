//
//  LoginView.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import Combine
import SwiftUI

struct LoginView: View {
    @StateObject private var store: LoginViewStore

    enum UIConst {
        static let padding: CGFloat = 5
    }
    
    init(store: LoginViewStore) {
        _store = .init(wrappedValue: store)
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground) // Adaptive background color
                .ignoresSafeArea() // Ensure the background covers the whole screen
            
            VStack {
                Spacer()
                
                CustomTextLabel(text: "iForest Login", textTypeSize: .navigationTitle)
                
                Spacer()
                
                CustomTextLabel(text: "E-mail", textTypeSize: .baseText)
                CustomTextField(placeHolder: "E-mail", imageName: "envelope", imageOpacity: 1, imageColor: .primary, value: $store.state.email) // Adapts to light/dark mode
                
                CustomTextLabel(text: "Password", textTypeSize: .baseText)
                CustomSecretTextField(placeHolder: "Password", imageName: "key", imageOpacity: 1, imageColor: .primary, value: $store.state.password) // Adapts to light/dark mode
                
                Toggle(isOn: $store.state.rememberMe) {
                    CustomTextLabel(text: "Remember me", textTypeSize: .caption)
                }
                .toggleStyle(SwitchToggleStyle(tint: .orange))
                .padding(.vertical, UIConst.padding)
                .onChange(of: store.state.rememberMe) { newValue in
                    if store.state.rememberMe {
                        store.send(.storeLogin(store.state.email))
                    } else {
                        store.send(.removeLogin)
                    }
                }
                
                Spacer()
                
                HStack {
                    LoginButton(buttonText: "SignIn", buttonTextColor: .white, buttonBackground: .indigo) {
                        store.signIn()
                    }
                    LoginButton(buttonText: "SignUp", buttonTextColor: .white, buttonBackground: .teal) {
                        store.signUp()
                    }
                }
                
                LoginButton(buttonText: "Skip Login", buttonTextColor: .white, buttonBackground: .gray) {
                    store.send(.skipLogin) // Trigger skip login action
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            store.send(.viewDidLoad)
        }
    }
}

#Preview {
    LoginView(store: LoginViewStore(keychainService: KeychainService(keychainManager: KeychainManager()), authManager: FirebaseAuthManager()))
}
