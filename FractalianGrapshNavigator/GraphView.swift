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
            Button("Reset") {
                withAnimation(.spring()) {
                    viewModel.focusedNode = nil
                }
            }
            .font(.title)
            
            HStack {
                Button("-") {
                    withAnimation(.spring()) {
                        viewModel.depth -= 1
                    }
                }
                .frame(width: 40, height: 40)
                .background(Color.red.opacity(0.3))
                
                Text("\(viewModel.depth)")
                
                Button("+") {
                    withAnimation(.spring()) {
                        viewModel.depth += 1
                    }
                }
                .frame(width: 40, height: 40)
                .background(Color.green.opacity(0.3))
            }.font(.title)

            ScrollView(.horizontal) {
                columnGraph()
                    .frame(height: 500)
                    .padding()
            }
        }
        .onAppear {
            viewModel.loadGraph()
        }
        .onChange(of: viewModel.focusedNode) { node in
            viewModel.loadGraph()
        }
        .onChange(of: viewModel.depth) { ned in
            viewModel.loadGraph()
        }
    }
    
    @ViewBuilder
    func columnGraph() -> some View {
        HStack(spacing: 16) {
            if let selectedNode = viewModel.focusedNode {
                GraphItemView(node: selectedNode)
                
                RecursiveGraphView(nodes: selectedNode.children, depth: viewModel.depth)
            } else {
                Text("Loading graph")
            }
        }
    }
}

struct RecursiveGraphView: View {
    let nodes: [Node]
    let depth: Int

    @ViewBuilder
    var body: some View {
        if depth > 0 {
            GraphItemGroup(nodes: nodes)
            
            RecursiveGraphView(nodes: nodes.flatMap(\.children).unique(), depth: depth - 1)
        }
    }
}


struct GraphItemGroup: View {
    let nodes: [Node]

    init(nodes: [Node]) {
        self.nodes = nodes
    }

    var body: some View {
        VStack {
            ForEach(nodes, id: \.id) { node in
                GraphItemView(node: node)
                    .padding(.vertical, 16)
            }
        }
    }
}

struct GraphItemView: View {
    let node: Node

    var body: some View {
        Text(node.id)
            .fontWeight(.bold)
            .foregroundColor(.blue)
            .aspectRatio(1, contentMode: .fit)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(lineWidth: 2)
            )
            .onTapGesture {
                withAnimation(.spring()) {
                    node.action?()
                }
            }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView(viewModel: GraphViewModel())
    }
}

extension Collection where Element: Hashable {
    func unique() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}

