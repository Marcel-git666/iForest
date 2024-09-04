//
//  AppCoordinator.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import SwiftUI

final class AppCoordinator: ObservableObject {
    @Published var path: NavigationPath
    
        init(path: NavigationPath) {
            self.path = path
        }
    
    @ViewBuilder
    func view() -> some View {
        if path.isEmpty {
            AuthenticationCoordinator(navigationPath: $path, output: .init(goToMainScreen: self.goToMainView)).view()
        }
        else {
            ProjectsCoordinator(navigationPath: $path).view()
        }
    }
    
    private func goToMainView() {
        path.append("Main view")
            
    }
}
