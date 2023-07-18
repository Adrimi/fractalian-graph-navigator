//
//  NodeView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 18/07/2023.
//

import SwiftUI

struct NodeView: View {
    let node: Node
    let updatePos: (CGPoint) -> Void
    @State private var rect: CGRect = .zero

    init(node: Node, updatePos: @escaping (CGPoint) -> Void) {
        self.node = node
        self.updatePos = updatePos
    }

    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .background(Color.white)
                    .padding(2)

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(lineWidth: 2)
                    .background(Color.white)
            }

            Text(node.id)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 50, maxHeight: 50)
        .trackPosition(binding: $rect)
        .onChange(of: rect, perform: { newValue in
            withAnimation(.spring()) {
                updatePos(CGPoint(x: newValue.midX, y: newValue.midY))
            }
        })
        .onTapGesture {
            withAnimation(.spring()) {
                node.action?()
            }
        }
    }
}
