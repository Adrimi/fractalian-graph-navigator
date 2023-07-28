//
//  GraphModels.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 16/07/2023.
//

import Foundation

struct Graph {
    let nodes: [Node]
    let edges: [Edge]
}

struct Node: Hashable, Equatable {
    let id: String
    var children: [Node] = []
    var action: (() -> Void)?

    init(id: String, children: [Node] = []) {
        self.id = id
        self.children = children
    }

    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Node {
    func withAllTree() -> [Node] {
        CollectionOfOne(self) + children.reduce(children) { partialResult, node in
            partialResult + node.withAllTree()
        }
    }
}

struct Edge: Hashable, Equatable {
    let source: String
    let target: String
}

struct NodePosition: Hashable, Equatable {
    let node: Node
    let position: CGPoint

    static func == (lhs: NodePosition, rhs: NodePosition) -> Bool {
        lhs.node == rhs.node
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(node)
    }
}
