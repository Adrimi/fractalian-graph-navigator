//
//  StackGraphView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 28/07/2023.
//

import SwiftUI

struct StackGraphView: View {
    @Binding var focusedNode: Node?
    @Binding var nodeSpacing: CGFloat
    var depth: Int
    
    var body: some View {
        ScrollThatFitsView {
            StackGraphLayerView(
                nodes: [focusedNode].compactMap { $0 },
                depth: depth,
                nodeSpacing: $nodeSpacing
            )
        }
    }
}
