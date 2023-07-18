//
//  NodeGroupView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 18/07/2023.
//

import SwiftUI

struct NodeGroupView: View {
    let nodes: [Node]
    let updatePos: (NodePosition) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(nodes, id: \.id) { node in
                NodeView(node: node) { newPosition in
                    updatePos(NodePosition(node: node, position: newPosition))
                }
                .padding(.vertical, 16)
            }
        }
    }
}

