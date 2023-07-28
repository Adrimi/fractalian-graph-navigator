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
    @Namespace var geometry

    @AppStorage("graphMode") var graphMode: GraphMode = .file
    @AppStorage("genNodesCount") var genNodesCount: String = "100"
    @AppStorage("genEdgesCount") var genEdgesCount: String = "400"
    @AppStorage("defaultDepth") var defaultDepth: String = "3"
    @AppStorage("nodeSpacing") var nodeSpacing: String = "16"
    @AppStorage("depthSpacing") var depthSpacing: String = "16"

    @State var graph: Graph?
    @State var focusedNode: Node?
    @State var visibleEdges: [Edge] = []
    @State var nodePositions: [NodePosition] = []
    @State var depth: Int = 2
    @State var isPresentingGeneratePanel: Bool = false
    @State var isPresentingError: Bool = false
    @State var error: GraphError? = nil
    @State var isLoading: Bool = false
    @State var disablePosUpdate: Bool = false

    private let maxZoom = 0.2
    private let minZoom = 5.0
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0

    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                guard currentZoom > maxZoom - 1.0 else {
                    return
                }
                guard currentZoom < minZoom - 1.0 else {
                    return
                }
                currentZoom = value - 1.0
            }
            .onEnded { _ in
                withAnimation(.spring()) {
                    totalZoom += currentZoom
                    currentZoom = 0
                    if totalZoom < maxZoom {
                        totalZoom = maxZoom
                    }
                    if totalZoom > minZoom {
                        totalZoom = minZoom
                    }
                }
            }
    }

    var doubleTapResetGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.spring()) {
                    totalZoom = 1.0
                }
            }
    }

    var visibleNodes: [Node] {
        guard let focusedNode = focusedNode else {
            return graph?.nodes ?? []
        }

        return CollectionOfOne(focusedNode) + focusedNode.getAllChildrenOfChildren()
    }

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
                disablePosUpdate: $disablePosUpdate,
                nodeSpacing: $nodeSpacing.asCGFloat,
                depthSpacing: $depthSpacing.asCGFloat,
                loadGraph: { loadGraph() }
            )

            InfoView(
                graph: graph,
                visibleNodes: visibleNodes,
                visibleEdges: visibleEdges
            )

            graphContentView()

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
        .background(
            Color.color1.ignoresSafeArea()
        )
    }

    @ViewBuilder
    func graphContentView() -> some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    columnGraph()
                        .drawingGroup()
                        .scaleEffect(currentZoom + totalZoom)
                        .id("columnGraph")
                        .onChange(of: depth) { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                proxy.scrollTo("columnGraph", anchor: .leading)
                            }
                        }
                }
            }
            .gesture(magnification)
            .gesture(doubleTapResetGesture)
            .background(Color.color2)

            LoadingView(isLoading: $isLoading)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .padding(.horizontal, 16)
        .shadow(radius: 16, x: 4, y: 4)
    }

    @ViewBuilder
    func columnGraph() -> some View {
        ZStack(alignment: .center) {
            if !disablePosUpdate {
                EdgesView(
                    positions: $nodePositions,
                    edges: $visibleEdges
                )
                .id(nodePositions.hashValue)
            }

            HStack(spacing: $depthSpacing.asCGFloat.wrappedValue) {
                ColumnGraphStackView(
                    alreadyVisibleNodes: [],
                    nodes: [focusedNode].compactMap { $0 },
                    depth: depth,
                    updatePos: { newNodePosition in
                        guard !disablePosUpdate else { return }
                        nodePositions.removeAll(where: { $0 == newNodePosition })
                        nodePositions.append(newNodePosition)
                    },
                    nodeSpacing: $nodeSpacing.asCGFloat,
                    namespace: geometry
                )
            }
            .coordinateSpace(name: "Graph")
        }
        .padding(.leading, 8)
        .border(Color.red, width: 2)
    }

    func refreshGraph() {
        setLoading(true)
        Task(priority: .background) {
            do {
                try await buildGraphStructure()
                setLoading(false)
            } catch {
                self.error = error as? GraphError
                self.isPresentingError = true
            }
        }
    }

    func loadGraph() {
        withAnimation {
            isLoading = true
        }
        Task(priority: .background) {
            do {
                self.focusedNode = nil
                self.graph = try await graphFromSelectedSource()
                try await buildGraphStructure()
                withAnimation {
                    isLoading = false
                }
            } catch {
                self.error = error as? GraphError
                self.isPresentingError = true
            }
        }
    }

    // MARK: - Helpers

    private func setLoading(_ loading: Bool) {
        guard visibleNodes.count <= 100 else {
            isLoading = false
            return
        }

        withAnimation {
            isLoading = loading
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

    private func buildGraphStructure() async throws {
        let mainNode = try await makeMainNode()
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

    private func makeMainNode() async throws -> Node {
        guard let id = pickNodeID() else {
            throw GraphError.noNodeID
        }

        let childrenTree = createChildrenTree(id: id, depth: depth - 1)
        let mainNode = createNode(id, children: childrenTree)

        return mainNode
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

extension Binding where Value == String {
    var asCGFloat: Binding<CGFloat> {
        .init(
            get: { CGFloat(Double(wrappedValue) ?? 0) },
            set: { wrappedValue = "\($0)" }
        )
    }
}
