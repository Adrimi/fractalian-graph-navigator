//
//  GraphViewModel.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 10/07/2023.
//

import Foundation
import SWXMLHash

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

class GraphViewModel: ObservableObject {
    @Published var focusedNode: Node?
    @Published var depth: Int = 3
    static let filename: String = "graph"

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

            if let firstID = focusedNode?.id {
                let childrenTree = createChildrenTree(from: edges, mainNodeID: firstID, depth: depth)
                focusedNode?.children = childrenTree
            } else {
                let firstID = edges.all.first(where: { edge in
                    edge.element?.attribute(by: "source")?.text != nil
                })!.element!.attribute(by: "source")!.text

                let childrenTree = createChildrenTree(from: edges, mainNodeID: firstID, depth: depth)
                let node = Node(id: firstID, children: childrenTree)
                focusedNode = node
            }
        } catch {
            print("Failed to load and parse the GraphML file: \(error)")
        }
    }

    func createChildrenTree(from edges: XMLIndexer, mainNodeID: String, depth: Int) -> [Node] {
        nextTargets(from: edges, mainNodeID: mainNodeID)
            .map { parent in
                let children = createChildrenTree(from: edges, mainNodeID: parent, depth: depth - 1)
                return createNode(parent, children: children)
            }
    }

    func nextTargets(from edges: XMLIndexer, mainNodeID: String) -> [String] {
        edges
            .filterAll { elem, _ in
                elem.attribute(by: "source")?.text == mainNodeID
            }
            .all
            .compactMap { $0.element?.attribute(by: "target")?.text }
    }
    
    func createNode(_ id: String, children: [Node] = []) -> Node {
        var node = Node(id: id, children: children)
        node.action = { self.focusedNode = node }
        return node
    }
}
