//
//  GraphGenerationService.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 17/07/2023.
//

import Foundation

class GraphGenerationService {
    static let filename: String = "graph"

    func generateGraph(numberOfNodes: Int, numberOfEdges: Int) async throws -> Graph {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let nodes = generateNodes(numberOfNodes: numberOfNodes)
                let edges = try generateEdges(nodes: nodes, numberOfEdges: numberOfEdges)
                let graph = Graph(nodes: nodes, edges: edges)

                continuation.resume(returning: graph)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func generateNodes(numberOfNodes: Int) -> [Node] {
        (1 ... numberOfNodes).map { i in
            Node(id: "\(i)")
        }
    }

    private func generateEdges(nodes: [Node], numberOfEdges: Int) throws -> [Edge] {
        guard nodes.count >= 2 else {
            throw GraphError.notEnoughNodes
        }
        var edges = [Edge]()

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
        
        return edges
    }
}
