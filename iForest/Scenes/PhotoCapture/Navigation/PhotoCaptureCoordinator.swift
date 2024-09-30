//
//  PhotoCaptureCoordinator.swift
//  iForest
//
//  Created by Marcel Mravec on 30.09.2024.
//

import Combine
import os
import SwiftUI
import UIKit

protocol PhotoCaptureCoordinating: NavigationControllerCoordinator {}

final class PhotoCaptureCoordinator: NSObject, PhotoCaptureCoordinating {
    private(set) var navigationController: UINavigationController
    private lazy var cancellables = Set<AnyCancellable>()
    private let eventSubject = PassthroughSubject<PhotoCaptureCoordinatorEvent, Never>()
    private let logger = Logger()
    var childCoordinators = [Coordinator]()

    // MARK: - Init with navigation controller
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Lifecycle
    deinit {
        logger.info("❌ Deinit PhotoCaptureCoordinator")
    }
    
    func start() {
        let store = PhotoViewStore()
        store.eventPublisher
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
            .store(in: &cancellables)
        
        let photoCaptureView = PhotoCaptureView(store: store)
        let viewController = UIHostingController(rootView: photoCaptureView)
        
        // Present the PhotoCaptureView
        navigationController.present(viewController, animated: true)
    }
    
    private func handleEvent(_ event: PhotoCaptureViewEvent) {
        switch event {
        case let .photoSaved(image):
            logger.info("📸 Photo saved")
            navigationController.dismiss(animated: true)
            
        case .cancel:
            logger.info("❌ Photo capture cancelled")
            navigationController.dismiss(animated: true)
        }
    }
}

extension PhotoCaptureCoordinator: EventEmitting {
    var eventPublisher: AnyPublisher<PhotoCaptureCoordinatorEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
}


