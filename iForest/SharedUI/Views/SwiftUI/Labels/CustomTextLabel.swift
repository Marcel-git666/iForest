//
//  CustomTextLabel.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import SwiftUI

struct CustomTextLabel: View {
    let text: String
    let textTypeSize: TextType
    var body: some View {
        Text(text)
            .textTypeModifier(textType: textTypeSize)
    }
}

#Preview {
    ZStack {
        Color.mint
        CustomTextLabel(text: "Login name", textTypeSize: .navigationTitle)
    }
    .ignoresSafeArea(.all)
}
