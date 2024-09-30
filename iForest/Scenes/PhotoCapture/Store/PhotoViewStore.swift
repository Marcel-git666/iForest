//
//  PhotoViewStore.swift
//  iForest
//
//  Created by Marcel Mravec on 30.09.2024.
//

import Combine
import Foundation
import UIKit
import os

final class PhotoViewStore: ObservableObject {
    private let logger = Logger()
    private let eventSubject = PassthroughSubject<PhotoCaptureViewEvent, Never>()
    
    @Published var capturedImage: UIImage? = nil
    var eventPublisher: AnyPublisher<PhotoCaptureViewEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    // MARK: - Send Actions
    @MainActor
    func send(_ action: PhotoViewAction) {
        switch action {
        case .startCamera:
            logger.info("📷 Starting camera")
            // Trigger the camera here

        case let .savePhoto(image):
            capturedImage = image
            eventSubject.send(.photoSaved(image))

        case .cancel:
            logger.info("❌ Cancelling photo capture")
            eventSubject.send(.cancel)
        }
    }
}

