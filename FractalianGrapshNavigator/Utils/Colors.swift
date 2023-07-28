//
//  Colors.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 24/07/2023.
//

import SwiftUI

extension Color {
    static let color1 = Color(0x264653)
    static let color2 = Color(0x2a9d8f)
    static let color3 = Color(0xe9c46a)
    static let color4 = Color(0xf4a261)
    static let color5 = Color(0xe76f51)
}

extension Color {
    init(_ hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
