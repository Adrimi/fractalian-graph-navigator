//
//  DynamicStack.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 24/07/2023.
//

import SwiftUI

struct DynamicStack<Content: View>: View {
    var horizontalAlignment = HorizontalAlignment.center
    var verticalAlignment = VerticalAlignment.center
    var spacing: CGFloat?
    @ViewBuilder var content: () -> Content
    
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        ViewThatFits {
            HStack(
                alignment: verticalAlignment,
                spacing: spacing,
                content: content
            )
            
            LazyVGrid(
                columns: (0..<2).map{_ in .init(.flexible(), spacing: 0)},
                alignment: horizontalAlignment,
                spacing: spacing,
                content: content
            )
            
            VStack(
                alignment: horizontalAlignment,
                spacing: spacing,
                content: content
            )
        }
    }
}
