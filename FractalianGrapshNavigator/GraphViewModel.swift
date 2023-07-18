//
//  GraphViewModel.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 10/07/2023.
//

import Foundation
import SwiftUI
import SWXMLHash

@MainActor
class GraphViewModel: ObservableObject {
    enum GraphMode: String, Hashable {
        case file
        case generated
    }

    var edgesCache: [Edge] = []
    var nodesCache: [Node] = []

    @Published var focusedNode: Node?
    @Published var visibleEdges: [Edge] = []
    @Published var visibleNodes: [Node] = []
    @Published var nodePositions: [NodePosition] = []
    @Published var depth: Int = 2

    @Published var isPresentingGeneratePanel: Bool = false
    @AppStorage("graphMode") var graphMode: GraphMode = .file
    @AppStorage("genNodesCount") var genNodesCount: String = "10"
    @AppStorage("genEdgesCount") var genEdgesCount: String = "10"
    @AppStorage("defaultDepth") var defaultDepth: String = "3"

    static let filename: String = "graph"

    init() {
        depth = Int(defaultDepth) ?? 3
        loadGraph()
    }

    func loadGraph() {
        Task(priority: .background) {
            switch graphMode {
            case .file:
                await loadGraphFromFile(Self.filename)
            case .generated:
                await generateGraph()
            }
        }
    }

    func loadGraphFromFile(_ fileName: String) async {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "xml") else {
            print("GraphML file not found")
            return
        }

        try? await withCheckedThrowingContinuation { continuation in
            do {
                let xmlData = try Data(contentsOf: url)
                let xml = XMLHash.parse(xmlData)

                let graphML = xml["graphml"]
                let graphElement = graphML["graph"]
                let edges = graphElement["edge"]

                // 1 - cache data
                nodesCache = graphElement["node"].all.compactMap {
                    guard let id = $0.element?.attribute(by: "id")?.text else {
                        return nil
                    }

                    return Node(id: id)
                }

                edgesCache = edges.all.compactMap { edge in
                    guard let source = edge.element?.attribute(by: "source")?.text,
                          let target = edge.element?.attribute(by: "target")?.text
                    else {
                        return nil
                    }

                    return Edge(source: source, target: target)
                }
            } catch {
                print("Failed to load and parse the GraphML file: \(error)")
            }

            continuation.resume()
        }

        await buildGraphStructure()
    }

    func generateGraph() async {
        guard let numberOfNodes = Int(genNodesCount),
              let numberOfEdges = Int(genEdgesCount)
        else {
            print("Invalid number of nodes or edges")
            return
        }

        let graphService = GraphService()
        await graphService.generateGraph(numberOfNodes: numberOfNodes, numberOfEdges: numberOfEdges)

        nodesCache = graphService.nodes
        edgesCache = graphService.edges

        await buildGraphStructure()
    }

    func buildGraphStructure() async {
        await withCheckedContinuation { continuation in
            // 1 - create note tree
            guard let id = pickNodeID() else {
                print("No node ID found")
                return
            }

            let childrenTree = createChildrenTree(id: id, depth: depth - 1)
            let mainNode = createNode(id, children: childrenTree)

            focusedNode = mainNode

            // 3 - filter out visible nodes and edges to present
            resetVisibleNodes()
            resetVisibleEdges()
            continuation.resume()
        }
    }

    func resetVisibleEdges() {
        visibleEdges = filteredEdges
    }
    
    var filteredEdges: [Edge] {
        edgesCache
            .filter { edge in
                visibleNodes.contains(where: { $0.id == edge.source }) && visibleNodes.contains(where: { $0.id == edge.target })
            }
    }

    func resetVisibleNodes() {
        visibleNodes = filteredNodes
    }
    
    var filteredNodes: [Node] {
        guard let node = focusedNode else {
            return []
        }
        
        let nodes = CollectionOfOne(node) + node.getAllChildrenOfChildren().unique()
        return nodes
    }

    func resetGraph() {
        focusedNode = nil
    }

    private func createChildrenTree(id: String, depth: Int) -> [Node] {
        guard depth > 0 else { return [] }

        return edgesCache
            .filter { $0.source == id }
            .map(\.target)
            .map { target in
                let children = createChildrenTree(id: target, depth: depth - 1)
                return createNode(target, children: children)
            }
    }

    private func createNode(_ id: String, children: [Node] = []) -> Node {
        var node = Node(id: id, children: children)
        node.action = { self.focusedNode = node }
        return node
    }

    private func pickNodeID() -> String? {
        if let firstID = focusedNode?.id {
            return firstID
        } else {
            return nodesCache.first?.id
        }
    }
}
