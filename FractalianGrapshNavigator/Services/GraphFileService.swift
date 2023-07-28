//
//  GraphFileService.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 21/07/2023.
//

import Foundation
import SWXMLHash

final class GraphFileService {
    static let filename: String = "graph"

    func loadGraphFromDefaultFile() async throws -> Graph {
        try await loadGraph(filename: Self.filename)
    }

    func loadGraph(filename: String, in bundle: Bundle = .main) async throws -> Graph {
        guard let url = bundle.url(forResource: filename, withExtension: "xml") else {
            throw GraphError.fileNotFound
        }

        return try await loadGraph(path: url)
    }

    func loadGraph(path: URL) async throws -> Graph {
        try await withCheckedThrowingContinuation { continuation in
            guard let xmlData = try? Data(contentsOf: path) else {
                continuation.resume(throwing: GraphError.invalidGraphMLFile)
                return
            }

            let xml = XMLHash.parse(xmlData)

            let graphML = xml["graphml"]
            let graphElement = graphML["graph"]
            guard graphElement.element != nil else {
                continuation.resume(throwing: GraphError.invalidGraphMLFile)
                return
            }

            let edgesElements = graphElement["edge"]
            let nodesElements = graphElement["node"]

            let nodes: [Node] = nodesElements.all.compactMap { node -> Node? in
                guard let id = node.element?.attribute(by: "id")?.text else {
                    return nil
                }

                return Node(id: id)
            }

            let edges: [Edge] = edgesElements.all.compactMap { edge -> Edge? in
                guard let source = edge.element?.attribute(by: "source")?.text,
                      let target = edge.element?.attribute(by: "target")?.text
                else {
                    return nil
                }

                return Edge(source: source, target: target)
            }

            let graph = Graph(nodes: nodes, edges: edges)

            continuation.resume(returning: graph)
        }
    }
}
