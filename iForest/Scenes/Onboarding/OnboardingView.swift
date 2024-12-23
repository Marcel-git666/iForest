//
//  OnboardingView.swift
//  iForest
//
//  Created by Marcel Mravec on 27.10.2024.
//

import Combine
import SwiftUI

struct OnboardingView: EventEmittingView {
    typealias Event = OnboardingViewEvent
    
    private let eventSubject = PassthroughSubject<OnboardingViewEvent, Never>()
    
    var body: some View {
        VStack {
            Text("Onboarding page 0")
            Button {
                eventSubject.send(.nextPage(from: 0))
            } label: {
                Text("Move to next screen")
            }
            .buttonStyle(OnboardingButtonStyle(color: .purple))
            Button {
                eventSubject.send(.close)
            } label: {
                Text("Dismiss onboarding")
            }
            .buttonStyle(OnboardingButtonStyle(color: .purple))
        }
    }
}

extension OnboardingView {
    var eventPublisher: AnyPublisher<Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }
}

#Preview {
    OnboardingView()
}

