//
//  ButtonStyles.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 24/07/2023.
//

import SwiftUI

// main button modifier
struct MainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.headline)
            .foregroundColor(Color.white)
            .padding(8)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.color5)
            )
            .shadow(radius: 16, x: 4, y: 4)
    }
}

// secondary button modifier
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.headline)
            .foregroundColor(Color.white)
            .padding(8)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.gray.opacity(0.4))
            )
            .shadow(radius: 8, x: 2, y: 2)
    }
}
