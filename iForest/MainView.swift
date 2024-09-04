//
//  MainView.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        Group {
            AuthenticationCoordinator(
                page: .login,
                navigationPath: $appCoordinator.path,
                output: .init(
                    goToMainScreen: {
                        print("Go to main screen (MainTabView)")
                    }
                )
            ).view()
        }
    }
}

#Preview {
    MainView()
}
