//
//  GraphView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 10/07/2023.
//

import SwiftUI

struct GraphView: View {
    @StateObject var viewModel: GraphViewModel
    @State var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Button("Reset") {
                    viewModel.focusedNode = nil
                }
                .buttonStyle(BorderedButtonStyle())

                VStack {
                    Text("Depth")

                    HStack {
                        Button("-") {
                            viewModel.depth -= 1
                        }
                        .buttonStyle(BorderedButtonStyle())

                        Text("\(viewModel.depth)")
                            .font(.title2)

                        Button("+") {
                            viewModel.depth += 1
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                    }
                }

                Button(action: { withAnimation(.spring()) {
                    alignment = alignment == .leading ? .trailing : .leading
                }}) {
                    Text("Toggle alignment")
                }
                .buttonStyle(BorderedButtonStyle())
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.gray.opacity(0.1))
            )
            

            ScrollView(.horizontal) {
                columnGraph()
                    .background(Color.green.opacity(0.15))
                    .padding()
                //                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer()
        }
        .onChange(of: viewModel.nodePositions, perform: { newValue in
            print("[onChange nodePositions] node pos counter \(newValue.count)")
            print("[onChange nodePositions] visible ndoes \(viewModel.visibleNodes.count)")
            if newValue.count == viewModel.visibleNodes.count {
                print("[onChange nodePositions] reloading edges")
                viewModel.resetVisibleEdges()
            }
        })
        .onChange(of: viewModel.focusedNode) { newValue in
            print("[onChange focusedNode] focused node changed to \(newValue?.id ?? "")")
            viewModel.loadGraph()
        }
        .onChange(of: viewModel.depth) { newValue in
            print("[onChange depth] depth changed to \(newValue)")
            viewModel.loadGraph()
        }
    }

    @ViewBuilder
    func columnGraph() -> some View {
        ZStack(alignment: .topLeading) {
            EdgesView(
                positions: $viewModel.nodePositions,
                edges: $viewModel.visibleEdges
            )
            .id(viewModel.nodePositions.hashValue)
            
            LazyVGrid(
                columns: (0..<viewModel.depth).map { _ in GridItem(.fixed(80)) },
                alignment: alignment,
                spacing: 16
            ) {
                ColumnGraphView(
                    alreadyVisibleNodes: [],
                    nodes: [viewModel.focusedNode].compactMap { $0 },
                    depth: viewModel.depth,
                    updatePos: { node, pos in
                        print("[updatePos] Node \(node.id) new pos \(pos)")
                        viewModel.nodePositions.removeAll(where: { $0.node == node })
                        if let pos {
                            viewModel.nodePositions.append(.init(node: node, position: pos))
                        }
                    }
                )
            }
            .coordinateSpace(name: "Graph")
        }
    }
}

struct ColumnGraphView: View {
    var alreadyVisibleNodes: [Node]
    let nodes: [Node]
    let depth: Int
    let updatePos: ((Node, CGPoint?)) -> Void
    
    init(
        alreadyVisibleNodes: [Node],
        nodes: [Node],
        depth: Int,
        updatePos: @escaping ((Node, CGPoint?)) -> Void
    ) {
        self.alreadyVisibleNodes = alreadyVisibleNodes
        self.nodes = nodes
        self.depth = depth
        self.updatePos = updatePos
    }

    var body: some View {
        if depth > 0 {
            NodeGroupView(nodes: nodes, updatePos: updatePos)

            ColumnGraphView(
                alreadyVisibleNodes: alreadyVisibleNodes + nodes,
                nodes: nodes
                    .flatMap(\.children)
                    .filter { !alreadyVisibleNodes.contains($0) }
                    .filter { !nodes.contains($0) }
                    .unique(),
                depth: depth - 1,
                updatePos: updatePos
            )
//            .offset(x: 80)
        }
    }
}

struct NodeGroupView: View {
    let nodes: [Node]
    let updatePos: ((Node, CGPoint?)) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(nodes, id: \.id) { node in
                NodeView(node: node) { pos in
                    updatePos((node, pos))
                }
                .padding(.vertical, 16)
                .opacity(0.2)
            }
        }
    }
}

struct NodeView: View {
    let node: Node
    let updatePos: (CGPoint?) -> Void
    @State private var rect: CGRect = .zero

    init(node: Node, updatePos: @escaping (CGPoint?) -> Void) {
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
            updatePos(CGPoint(x: newValue.midX, y: newValue.midY))
        })
        .onTapGesture {
//            withAnimation(.spring()) {
                node.action?()
//            }
        }
        .onAppear { print("Node \(node.id) appeared") }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView(viewModel: GraphViewModel())
    }
}
