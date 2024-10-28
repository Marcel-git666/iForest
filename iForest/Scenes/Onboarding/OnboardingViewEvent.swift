//
//  OnboardingViewEvent.swift
//  iForest
//
//  Created by Marcel Mravec on 27.10.2024.
//

import Foundation

protocol OnboardingEvent {}

enum OnboardingViewEvent: OnboardingEvent {
    case nextPage(from: Int)
    case close
}
