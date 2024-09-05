//
//  NavigationControllerCoordinator.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import UIKit

protocol NavigationControllerCoordinator: ViewControllerCoordinator {
    var navigationController: UINavigationController { get }
}

extension NavigationControllerCoordinator {
    var rootViewController: UIViewController {
        navigationController
    }
}
