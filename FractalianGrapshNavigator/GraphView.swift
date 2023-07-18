//
//  GraphView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 10/07/2023.
//

import SwiftUI

struct GraphView: View {
    @StateObject var viewModel: GraphViewModel

    var body: some View {
        VStack {
            ControlPanelView(viewModel: viewModel)

            ViewThatFits(in: .horizontal) {
                columnGraph()
                    .background(Color.green.opacity(0.15))
                    .padding()

                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    columnGraph()
                        .background(Color.green.opacity(0.15))
                        .padding()
                }
            }

            Spacer()
        }
        .onChange(of: viewModel.focusedNode) { _ in
            Task {
                await viewModel.buildGraphStructure()
            }
        }
        .onChange(of: viewModel.depth) { _ in
            Task {
                await viewModel.buildGraphStructure()
            }
        }
        .onChange(of: viewModel.defaultDepth) { newValue in
            guard let intValue = Int(newValue) else { return }
            viewModel.depth = intValue
        }
    }

    @ViewBuilder
    func columnGraph() -> some View {
        ZStack(alignment: .top) {
            EdgesView(
                positions: $viewModel.nodePositions,
                edges: $viewModel.visibleEdges
            )
            .id(viewModel.nodePositions.hashValue)

            LazyVGrid(
                columns: (0 ..< viewModel.depth).map { _ in GridItem(.fixed(80)) },
                spacing: 16
            ) {
                ColumnGraphStackView(
                    alreadyVisibleNodes: [],
                    nodes: [viewModel.focusedNode].compactMap { $0 },
                    depth: viewModel.depth,
                    updatePos: { newNodePosition in
                        viewModel.nodePositions.removeAll(where: { $0 == newNodePosition })
                        viewModel.nodePositions.append(newNodePosition)
                    }
                )
            }
            .coordinateSpace(name: "Graph")
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView(viewModel: GraphViewModel())
    }
}
