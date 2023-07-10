//
//  GraphView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 10/07/2023.
//

import SwiftUI

struct GraphView: View {
    @StateObject var viewModel: GraphViewModel

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        VStack {
            Button("Reset") {
                withAnimation(.spring()) {
                    viewModel.focusedNode = nil
                }
            }

            columnGraph()
                .frame(height: 500)
        }
        .onAppear {
            viewModel.loadGraph()
        }
        .onChange(of: viewModel.focusedNode) { _ in
            viewModel.loadGraph()
        }
    }

    @ViewBuilder
    func columnGraph() -> some View {
        HStack(spacing: 16) {
            if let selectedNode = viewModel.focusedNode {
                GraphItemView(node: selectedNode)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.green.opacity(0.3))
                    )

                VStack {
                    GraphItemGroup(nodes: selectedNode.children)
                }

                VStack {
                    ForEach(selectedNode.children, id: \.id) { node in
                        GraphItemGroup(nodes: node.children)
                    }
                }

                VStack {
                    ForEach(selectedNode.children, id: \.id) { node in
                        ForEach(node.children, id: \.id) { node in
                            GraphItemGroup(nodes: node.children)
                        }
                    }
                }
            } else {
                Text("Loading graph")
            }
        }
    }
}

struct GraphItemGroup: View {
    let nodes: [Node]

    init(nodes: [Node]) {
        self.nodes = nodes
    }

    var body: some View {
        ForEach(nodes, id: \.id) { node in
            Spacer()
            GraphItemView(node: node)
            Spacer()
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
    static var testNode: Node = {
        Node(id: "A", children: [
            Node(id: "B"),
            Node(id: "C", children: [
                Node(id: "D"),
                Node(id: "E"),
                Node(id: "F", children: [
                    Node(id: "G"),
                    Node(id: "H"),
                    Node(id: "I"),
                ]),
            ]),
        ])
    }()

    static var viewModel: GraphViewModel {
        let vm = GraphViewModel()
//        vm.focusedNode = testNode
        return vm
    }

    static var previews: some View {
        GraphView(viewModel: viewModel)
    }
}
