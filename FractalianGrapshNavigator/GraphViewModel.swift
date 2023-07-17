//
//  GraphViewModel.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 10/07/2023.
//

import Foundation
import SWXMLHash

@MainActor
class GraphViewModel: ObservableObject {
    @Published var edgesCache: [Edge] = []
    @Published var nodesCache: [Node] = []

    @Published var focusedNode: Node?
    @Published var visibleEdges: [Edge] = []
    @Published var visibleNodes: [Node] = []
    @Published var nodePositions: [NodePosition] = []
    @Published var depth: Int = 2
    static let filename: String = "graph"

    init() {
        loadGraph()
    }

    func loadGraph(_ fileName: String = filename) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "xml") else {
            print("GraphML file not found")
            return
        }

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

            // 2 - create note tree
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
        } catch {
            print("Failed to load and parse the GraphML file: \(error)")
        }
    }

    func resetVisibleEdges() {
        visibleEdges = edgesCache
            .filter { edge in
                visibleNodes.contains(where: { $0.id == edge.source }) && visibleNodes.contains(where: { $0.id == edge.target })
            }
        print("[resetVisibleEdges] \(visibleEdges.count)/\(edgesCache.count) visible: \(visibleEdges.map { "\($0.source) -> \($0.target)" }.joined(separator: ", "))")
    }

    func resetVisibleNodes() {
        guard let node = focusedNode else { return }
        let visible = CollectionOfOne(node) + node.getAllChildrenOfChildren().unique()
        visibleNodes = visible
        print("[resetVisibleNodes] \(visible.count)/\(nodesCache.count) visible")
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

