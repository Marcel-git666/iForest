//
//  UIViewController+Ext.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import UIKit

extension UIViewController {
    func showInfoAlert(title: String, message: String? = nil, handler: (() -> Void)? = nil) {
        guard presentedViewController == nil else {
            return
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(
            title: "OK",
            style: .default
        ) { _ in
            handler?()
        }
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }
}
