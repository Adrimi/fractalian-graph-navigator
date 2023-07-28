//
//  InfoView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 28/07/2023.
//

import SwiftUI

struct InfoView: View {
    let graph: Graph?
    let visibleNodes: [Node]
    let visibleEdges: [Edge]

    var body: some View {
        DynamicStack {
            Text("Total Nodes count: \(graph?.nodes.count ?? 0)")
            Text("Total Edges count: \(graph?.edges.count ?? 0)")
            Text("Visible Nodes count: \(visibleNodes.count)")
            Text("Visible Edges count: \(visibleEdges.count)")
        }
        .font(.caption)
        .foregroundColor(Color.white)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(8)
    }
}
