//
//  TextType.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import SwiftUI
import UIKit

enum TextType {
    case navigationTitle
    case sectionTitle
    case baseText
    case caption
}

// MARK: - TextType attributes SwiftUI
extension TextType {
    var font: Font {
        switch self {
        case .navigationTitle:
            .bold(with: .size28)
        case .caption:
            .regular(with: .size12)
        case .baseText:
            .regular(with: .size18)
        case .sectionTitle:
            .mediumItalic(with: .size22)
        }
    }

    var color: Color {
        .blue
    }
}

// MARK: - TextType attributes UIKit
//extension TextType {
//    var uiFont: UIFont {
//        switch self {
//        case .navigationTitle:
//            .bold(with: .size28)
//        case .caption:
//            .regular(with: .size12)
//        case .baseText:
//            .regular(with: .size18)
//        case .sectionTitle:
//            .mediumItalic(with: .size22)
//        }
//    }
//
//    var uiColor: UIColor {
//        .white
//    }
//}
