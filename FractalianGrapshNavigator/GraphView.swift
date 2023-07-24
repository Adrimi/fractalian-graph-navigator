//
//  GraphView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 10/07/2023.
//

import SwiftUI

enum GraphMode: String, Hashable {
    case file
    case generated
}

struct GraphView: View {
    @AppStorage("graphMode") var graphMode: GraphMode = .file
    @AppStorage("genNodesCount") var genNodesCount: String = "10"
    @AppStorage("genEdgesCount") var genEdgesCount: String = "10"
    @AppStorage("defaultDepth") var defaultDepth: String = "3"

    @State var graph: Graph?
    @State var focusedNode: Node?
    @State var visibleEdges: [Edge] = []
    @State var nodePositions: [NodePosition] = []
    @State var depth: Int = 2
    @State var isPresentingGeneratePanel: Bool = false
    @State var isPresentingError: Bool = false
    @State var error: GraphError? = nil
    @State var isLoadingGraph: Bool = false

    init() {
        depth = Int(defaultDepth) ?? 3
    }

    var body: some View {
        VStack {
            ControlPanelView(
                graph: $graph,
                focusedNode: $focusedNode,
                depth: $depth,
                isPresentingGeneratePanel: $isPresentingGeneratePanel,
                genNodesCount: $genNodesCount,
                genEdgesCount: $genEdgesCount,
                defaultDepth: $defaultDepth,
                graphMode: $graphMode,
                loadGraph: { loadGraph() }
            )
            
            ZStack {
                
                Color.blue.opacity(0.05)
                
                ZoomableContainer {
                    ScrollView([.horizontal, .vertical], showsIndicators: false) {
                        columnGraph()
                            .background(Color.red.opacity(0.05))
                    }
                    .background(Color.green.opacity(0.05))
                }
                .padding()
                
                if isLoadingGraph {
                    ZStack {
                        VisualEffect(style: .systemUltraThinMaterial)
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(8)
                    }
                }
                
            }
            .clipped()

            Spacer()
        }
        .onAppear {
            loadGraph()
        }
        .alert(isPresented: $isPresentingError) {
            Alert(
                title: Text("Error"),
                message: Text(error?.message ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: focusedNode) { _ in
            refreshGraph()
        }
        .onChange(of: depth) { _ in
            refreshGraph()
        }
        .onChange(of: defaultDepth) { newValue in
            guard let intValue = Int(newValue) else { return }
            depth = intValue
        }
    }

    @ViewBuilder
    func columnGraph() -> some View {
        ZStack(alignment: .top) {
            EdgesView(
                positions: $nodePositions,
                edges: $visibleEdges
            )
            .id(nodePositions.hashValue)

            LazyVGrid(
                columns: (0 ..< depth).map { _ in GridItem(.fixed(80)) },
                spacing: 16
            ) {
                ColumnGraphStackView(
                    alreadyVisibleNodes: [],
                    nodes: [focusedNode].compactMap { $0 },
                    depth: depth,
                    updatePos: { newNodePosition in
                        nodePositions.removeAll(where: { $0 == newNodePosition })
                        nodePositions.append(newNodePosition)
                    }
                )
            }
            .coordinateSpace(name: "Graph")
        }
    }

    func refreshGraph() {
        withAnimation {
            isLoadingGraph = true
        }
        Task(priority: .background) {
            do {
                try await buildGraphStructure()
                withAnimation {
                    isLoadingGraph = false
                }
            } catch {
                self.error = error as? GraphError
                self.isPresentingError = true
            }
        }
    }

    func loadGraph() {
        withAnimation {
            isLoadingGraph = true
        }
        Task(priority: .background) {
            do {
                self.focusedNode = nil
                self.graph = try await graphFromSelectedSource()
                try await buildGraphStructure()
                withAnimation {
                    isLoadingGraph = false
                }
            } catch {
                self.error = error as? GraphError
                self.isPresentingError = true
            }
        }
    }

    private func graphFromSelectedSource() async throws -> Graph {
        switch graphMode {
        case .file:
            return try await GraphFileService().loadGraphFromDefaultFile()
        case .generated:
            return try await GraphMapper().generateGraph(
                genNodesCount: genNodesCount,
                genEdgesCount: genEdgesCount
            )
        }
    }

    func buildGraphStructure() async throws {
        let mainNode: Node = try await withCheckedThrowingContinuation { [depth] continuation in
            guard let id = pickNodeID() else {
                continuation.resume(throwing: GraphError.noNodeID)
                return
            }

            let childrenTree = createChildrenTree(id: id, depth: depth - 1)
            let mainNode = createNode(id, children: childrenTree)

            continuation.resume(returning: mainNode)
        }

        let vnodes = await presentableNodes(mainNode: mainNode)
        let vedges = await presentableEdges(visibleNodes: vnodes, allEdges: graph?.edges ?? [])
            
        // invalidate before applying to force reload view
        focusedNode = nil
        focusedNode = mainNode
        visibleEdges = vedges
    }

    private func presentableNodes(mainNode: Node) async -> [Node] {
        CollectionOfOne(mainNode) + mainNode.getAllChildrenOfChildren().unique()
    }

    private func presentableEdges(visibleNodes: [Node], allEdges: [Edge]) async -> [Edge] {
        allEdges.filter { edge in
            visibleNodes.contains(where: { $0.id == edge.source }) &&
                visibleNodes.contains(where: { $0.id == edge.target })
        }
    }

    private func createChildrenTree(id: String, depth: Int) -> [Node] {
        guard depth > 0 else { return [] }
        let edges = graph?.edges ?? []

        return edges
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
            return graph?.nodes.first?.id
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView()
    }
}
