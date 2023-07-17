//
//  GraphModels.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 16/07/2023.
//

import Foundation

struct Graph {
    var nodes: [Node] = []
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
    func getAllChildrenOfChildren() -> [Node] {
        children.reduce(children) { partialResult, node in
            partialResult + node.getAllChildrenOfChildren()
        }
    }
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

struct Edge: Hashable, Equatable {
    let source: String
    let target: String
}
