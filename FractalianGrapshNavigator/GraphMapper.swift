//
//  GraphMapper.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 21/07/2023.
//

import Foundation

final class GraphMapper {
    func generateGraph(genNodesCount: String, genEdgesCount: String) async throws -> Graph {
        guard let numberOfNodes = Int(genNodesCount),
              let numberOfEdges = Int(genEdgesCount)
        else {
            throw GraphError.notANumber
        }

        let graphService = GraphGenerationService()
        let graph = try await graphService.generateGraph(
            numberOfNodes: numberOfNodes,
            numberOfEdges: numberOfEdges
        )
        return graph
    }
}
