//
//  ColumnGraphView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 28/07/2023.
//

import SwiftUI

struct ColumnGraphView: View {
    @Binding var nodePositions: [NodePosition]
    @Binding var visibleEdges: [Edge]
    @Binding var disablePosUpdate: Bool
    @Binding var focusedNode: Node?
    @Binding var depthSpacing: CGFloat
    @Binding var nodeSpacing: CGFloat
    var depth: Int
    var namespace: Namespace.ID

    var body: some View {
        ZStack(alignment: .center) {
            if !disablePosUpdate {
                ColumnGraphEdgesView(
                    positions: $nodePositions,
                    edges: $visibleEdges
                )
                .id(nodePositions.hashValue)
            }

            HStack(spacing: depthSpacing) {
                ColumnGraphNodesView(
                    alreadyVisibleNodes: [],
                    nodes: [focusedNode].compactMap { $0 },
                    depth: depth,
                    updatePos: { newNodePosition in
                        guard !disablePosUpdate else { return }
                        nodePositions.removeAll(where: { $0 == newNodePosition })
                        nodePositions.append(newNodePosition)
                    },
                    nodeSpacing: $nodeSpacing,
                    namespace: namespace
                )
            }
            .coordinateSpace(name: "Graph")
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.color4)
                .opacity(0.3)
                .mask(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(lineWidth: 2)
                )
        )
    }
}
