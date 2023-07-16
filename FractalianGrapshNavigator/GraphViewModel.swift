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

extension Node {
    func getAllChildrenOfChildren() -> [Node] {
//        var allChildren = children
//        for child in children {
//            allChildren.append(contentsOf: child.getAllChildrenOfChildren())
//        }
//        return allChildren
//
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
            self.nodesCache = graphElement["node"].all.compactMap {
                guard let id = $0.element?.attribute(by: "id")?.text else {
                    return nil
                }
                
                return Node(id: id)
            }
            
            self.edgesCache = edges.all.compactMap { edge in
                guard let source = edge.element?.attribute(by: "source")?.text,
                      let target = edge.element?.attribute(by: "target")?.text else {
                    return nil
                }
                
                return Edge(source: source, target: target)
            }
            
            // 2 - create note tree
            let id = pickNodeID(edges)
            let childrenTree = createChildrenTree(
                from: edges,
                mainNodeID: id,
                depth: depth - 1
            )
            let mainNode = createNode(id, children: childrenTree)
            
            focusedNode = mainNode
            self.visibleNodes = [mainNode] + mainNode.getAllChildrenOfChildren()

        } catch {
            print("Failed to load and parse the GraphML file: \(error)")
        }
    }

    func createChildrenTree(from edges: XMLIndexer, mainNodeID: String, depth: Int) -> [Node] {
        guard depth > 0 else { return [] }
        
        return nextTargets(from: edges, mainNodeID: mainNodeID)
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
    
    func pickNodeID(_ edges: XMLIndexer) -> String {
        if let firstID = focusedNode?.id {
            return firstID
        } else {
            return edges.all.first(where: { edge in
                edge.element?.attribute(by: "source")?.text != nil
            })!.element!.attribute(by: "source")!.text
        }
    }
    
    func reloadEdges() {
        self.visibleEdges = edgesCache
            .filter { edge in
                visibleNodes.contains(where: { $0.id == edge.source }) && visibleNodes.contains(where: { $0.id == edge.target })
            }
            .printing { print("\($0.source) -> \($0.target)") }
        print("visible edges counter \(visibleEdges.count)")
    }
}

extension Collection {
    func printing(_ handler: (Element) -> Void) -> [Element] {
        map { handler($0); return $0 }
    }
}
