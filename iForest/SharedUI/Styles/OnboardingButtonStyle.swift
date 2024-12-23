//
//  OnboardingButtonStyle.swift
//  iForest
//
//  Created by Marcel Mravec on 27.10.2024.
//

import SwiftUI

struct OnboardingButtonStyle: ButtonStyle {
    // MARK: UI constants
    private enum StyleConstant {
        static let padding: CGFloat = 10
        static let opacity: CGFloat = 0.5
        static let scaleEffectMin: CGFloat = 0.7
        static let scaleEffectMax: CGFloat = 1
        static let cornerRadius: CGFloat = 8
    }

    // MARK: Public variables
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(StyleConstant.padding)
            .background(color.opacity(StyleConstant.padding))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: StyleConstant.cornerRadius))
            .scaleEffect(configuration.isPressed ? StyleConstant.scaleEffectMin : StyleConstant.scaleEffectMax)
            .animation(.easeInOut, value: configuration.isPressed)
            .contentShape(Rectangle())
    }
}
