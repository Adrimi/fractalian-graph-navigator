//
//  ColumnGraphStackView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 18/07/2023.
//

import SwiftUI

struct ColumnGraphStackView: View {
    var alreadyVisibleNodes: [Node]
    let nodes: [Node]
    let depth: Int
    let updatePos: (NodePosition) -> Void

    init(
        alreadyVisibleNodes: [Node],
        nodes: [Node],
        depth: Int,
        updatePos: @escaping (NodePosition) -> Void
    ) {
        self.alreadyVisibleNodes = alreadyVisibleNodes
        self.nodes = nodes
        self.depth = depth
        self.updatePos = updatePos
    }

    var body: some View {
        if depth > 0 {
            NodeGroupView(nodes: nodes, updatePos: updatePos)

            ColumnGraphStackView(
                alreadyVisibleNodes: alreadyVisibleNodes + nodes,
                nodes: nodes
                    .flatMap(\.children)
                    .filter { !alreadyVisibleNodes.contains($0) }
                    .filter { !nodes.contains($0) }
                    .unique(),
                depth: depth - 1,
                updatePos: updatePos
            )
        }
    }
}

