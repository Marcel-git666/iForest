//
//  MainTabBarView.swift
//  iForest
//
//  Created by Marcel Mravec on 02.11.2024.
//

import SwiftUI

struct MainTabBarView: UIViewControllerRepresentable {
    let tabBarController: UITabBarController

    func makeUIViewController(context: Context) -> UITabBarController {
        return tabBarController
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        // Nothing needed here for now
    }
}
