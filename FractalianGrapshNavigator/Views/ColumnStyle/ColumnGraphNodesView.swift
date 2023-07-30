//
//  ColumnGraphNodesView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 18/07/2023.
//

import SwiftUI

struct ColumnGraphNodesView: View {
    var alreadyVisibleNodes: [Node]
    let nodes: [Node]
    let depth: Int
    let updatePos: (NodePosition) -> Void
    @Binding var nodeSpacing: CGFloat
    var namespace: Namespace.ID

    init(
        alreadyVisibleNodes: [Node],
        nodes: [Node],
        depth: Int,
        updatePos: @escaping (NodePosition) -> Void,
        nodeSpacing: Binding<CGFloat>,
        namespace: Namespace.ID
    ) {
        self.alreadyVisibleNodes = alreadyVisibleNodes
        self.nodes = nodes
        self.depth = depth
        self.updatePos = updatePos
        _nodeSpacing = nodeSpacing
        self.namespace = namespace
    }

    var body: some View {
        if depth > 0 && !nodes.isEmpty {
            VStack(alignment: .center, spacing: nodeSpacing) {
                ForEach(nodes, id: \.id) { node in
                    ColumnGraphNodeView(node: node, namespace: namespace) { newPosition in
                        updatePos(NodePosition(node: node, position: newPosition))
                    }
                }
            }

            ColumnGraphNodesView(
                alreadyVisibleNodes: alreadyVisibleNodes + nodes,
                nodes: nodes
                    .flatMap(\.children)
                    .filter { !alreadyVisibleNodes.contains($0) }
                    .filter { !nodes.contains($0) }
                    .unique(),
                depth: depth - 1,
                updatePos: updatePos,
                nodeSpacing: $nodeSpacing,
                namespace: namespace
            )
        }
    }
}
