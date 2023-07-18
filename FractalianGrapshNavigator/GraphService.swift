//
//  GraphService.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 17/07/2023.
//

import Foundation

class GraphService {
    var nodes: [Node] = []
    var edges: [Edge] = []

    func generateGraph(numberOfNodes: Int, numberOfEdges: Int) async {
        await withCheckedContinuation { continuation in
            generateNodes(numberOfNodes: numberOfNodes)
            generateEdges(numberOfEdges: numberOfEdges)
            continuation.resume()
        }
    }

    func generateNodes(numberOfNodes: Int) {
        for i in 1 ... numberOfNodes {
            let node = Node(id: "\(i)")
            nodes.append(node)
        }
    }

    func generateEdges(numberOfEdges: Int) {
        guard nodes.count >= 2 else {
            print("Need at least 2 nodes to generate edges.")
            return
        }

        for _ in 1 ... numberOfEdges {
            var sourceNodeIndex = Int(arc4random_uniform(UInt32(nodes.count)))
            var targetNodeIndex = Int(arc4random_uniform(UInt32(nodes.count)))

            while sourceNodeIndex == targetNodeIndex {
                targetNodeIndex = Int(arc4random_uniform(UInt32(nodes.count)))
            }
            
            // combination without repetition
            while edges.contains(where: { $0.source == nodes[sourceNodeIndex].id && $0.target == nodes[targetNodeIndex].id }) {
                sourceNodeIndex = Int(arc4random_uniform(UInt32(nodes.count)))
                targetNodeIndex = Int(arc4random_uniform(UInt32(nodes.count)))
            }

            let edge = Edge(
                source: nodes[sourceNodeIndex].id,
                target: nodes[targetNodeIndex].id
            )

            edges.append(edge)
        }
    }
}
