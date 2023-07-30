//
//  ScrollThatFitsView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 30/07/2023.
//

import SwiftUI

struct ScrollThatFitsView<Content: View>: View {
    let content: () -> Content

    var body: some View {
        ViewThatFits(in: .vertical) {
            content()

            ScrollView(.vertical) {
                content()
            }
        }
    }
}
