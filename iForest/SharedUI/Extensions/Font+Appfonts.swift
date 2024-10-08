//
//  Font+Appfonts.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import SwiftUI

extension Font {
    static func regular(with size: FontSize) -> Font {
        Font.custom(FontType.regular.rawValue, size: size.rawValue)
    }
    static func bold(with size: FontSize) -> Font {
        Font.custom(FontType.bold.rawValue, size: size.rawValue)
    }
    static func mediumItalic(with size: FontSize) -> Font {
        Font.custom(FontType.mediumItalic.rawValue, size: size.rawValue)
    }
}
