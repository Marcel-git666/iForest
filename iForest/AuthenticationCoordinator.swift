//
//  AuthenticationCoordinator.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import SwiftUI

//enum AuthenticationPage {
//    case login, forgotPassword
//}

final class AuthenticationCoordinator: Hashable {
    @Binding var navigationPath: NavigationPath
    
    private var id = UUID()
    private var output: Output?
    //    private var page: AuthenticationPage
    
    struct Output {
        var goToMainScreen: () -> Void
    }
    
    init(navigationPath: Binding<NavigationPath>, output: Output? = nil) {
        self._navigationPath = navigationPath
        self.output = output
    }
    
    @ViewBuilder
    func view() -> some View {
        LoginView(output: .init(goToMainScreen: self.output?.goToMainScreen ?? {}))
    }
    
    static func == (lhs: AuthenticationCoordinator, rhs: AuthenticationCoordinator) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
