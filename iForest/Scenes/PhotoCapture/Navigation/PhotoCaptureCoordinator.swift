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
        
        // Capture 'self' outside the Task block safely
        store.eventPublisher
            .sink { [weak self] event in
                guard let strongSelf = self else { return } // Capture 'self' before the Task
                
                // Now, run the Task within a safe context
                Task { @MainActor in
                    strongSelf.handleEvent(event) // Safe to call 'handleEvent' with strong reference
                }
            }
            .store(in: &cancellables)
        
        let photoCaptureView = PhotoCaptureView(store: store)
        let viewController = UIHostingController(rootView: photoCaptureView)
        
        // Present the PhotoCaptureView
        navigationController.present(viewController, animated: true)
    }

    
    @MainActor 
    private func handleEvent(_ event: PhotoCaptureViewEvent) {
        switch event {
        case let .photoSaved(image):
            logger.info("📸 Photo saved")
            navigationController.dismiss(animated: true)
            // print("ViewControllers: \(navigationController.viewControllers)")
            // Pass the captured image to the store (e.g., StandViewStore)
            if let standViewController = navigationController.viewControllers.first(where: { $0 is UIHostingController<StandView> }) as? UIHostingController<StandView> {
                Task { @MainActor in
                    standViewController.rootView.store.send(.photoCaptured(image: image))
                }
            } else {
                logger.error("❌ Failed to find StandView in the navigation stack")
            }
            
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


