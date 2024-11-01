//
//  TabBarControllerCoordinator.swift
//  iForest
//
//  Created by Marcel Mravec on 01.11.2024.
//

import UIKit

protocol TabBarControllerCoordinator: ViewControllerCoordinator {
    var tabBarController: UITabBarController { get }
}

extension TabBarControllerCoordinator {
    var rootViewController: UIViewController {
        tabBarController
    }
}
