//
//  StackGraphLayerView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 30/07/2023.
//

import SwiftUI

struct StackGraphLayerView: View {
    enum Constants {
        static let verticalPadding: CGFloat = 40
        static let horizontalPadding: CGFloat = 8
    }

    @Binding var nodeSpacing: CGFloat
    let nodes: [Node]
    let depth: Int

    init(
        nodes: [Node],
        depth: Int,
        nodeSpacing: Binding<CGFloat>
    ) {
        self.nodes = nodes
        self.depth = depth
        _nodeSpacing = nodeSpacing
    }

    var body: some View {
        if depth > 0 && !nodes.isEmpty {
            VStack(spacing: nodeSpacing) {
                ForEach(nodes, id: \.idDepth) { node in
                    ZStack {
                        StackGraphNodeView(
                            node: node
                        )
                        StackGraphLayerView(
                            nodes: node.children,
                            depth: depth - 1,
                            nodeSpacing: $nodeSpacing
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, Constants.verticalPadding)
            .padding(.horizontal, Constants.horizontalPadding)
        }
    }
}
