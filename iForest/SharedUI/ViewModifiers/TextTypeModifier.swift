//
//  TextTypeModifier.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import SwiftUI

struct TextTypeModifier: ViewModifier {
    let textType: TextType
    func body(content: Content) -> some View {
        content
            .font(textType.font)
            .foregroundColor(textType.color)
    }
}

extension View {
    func textTypeModifier(textType: TextType) -> some View {
        self.modifier(TextTypeModifier(textType: textType))
    }
}
