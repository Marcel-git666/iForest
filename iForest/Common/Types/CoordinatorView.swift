//
//  CoordinatorView.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import SwiftUI
import UIKit

struct CoordinatorView<T: ViewControllerCoordinator>: UIViewControllerRepresentable {
    let coordinator: T
    
    func makeUIViewController(context: Context) -> UIViewController {
        return coordinator.rootViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
