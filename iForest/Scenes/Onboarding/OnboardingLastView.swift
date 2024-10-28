//
//  OnboardingLastView.swift
//  iForest
//
//  Created by Marcel Mravec on 27.10.2024.
//

import Combine
import SwiftUI

struct OnboardingLastView: EventEmittingView {
    typealias Event = OnboardingViewEvent
    @State private var seenOnboarding = false
    private let eventSubject = PassthroughSubject<OnboardingViewEvent, Never>()
    
    var body: some View {
        VStack {
            Text("Onboarding page 2")
            Toggle(isOn: $seenOnboarding) {
                Text("Don't show onboarding again")
                    .font(.subheadline)
            }
            .padding()
            Button { // swiftlint:disable:next no_magic_numbers
                eventSubject.send(.nextPage(from: 2))
            } label: {
                Text("Back to first page")
            }
            .buttonStyle(OnboardingButtonStyle(color: .purple))
            Button {
                if seenOnboarding {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                }
                eventSubject.send(.close)
            } label: {
                Text("Dismiss onboarding")
            }
            .buttonStyle(OnboardingButtonStyle(color: .purple))
        }
    }
}

extension OnboardingLastView {
    var eventPublisher: AnyPublisher<Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }
}

#Preview {
    OnboardingLastView()
}
