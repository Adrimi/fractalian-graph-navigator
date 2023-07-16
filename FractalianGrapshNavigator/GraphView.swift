//
//  GraphView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 10/07/2023.
//

import SwiftUI

struct GraphView: View {
    @StateObject var viewModel: GraphViewModel
    @State var alignment: Alignment = .topLeading

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Button("Reset") {
                    withAnimation(.spring()) {
                        viewModel.focusedNode = nil
                    }
                }
                .buttonStyle(BorderedButtonStyle())

                VStack {
                    Text("Depth")

                    HStack {
                        Button("-") {
                            viewModel.depth -= 1
                        }
                        .buttonStyle(BorderedButtonStyle())

                        Text("\(viewModel.depth)")
                            .font(.title2)

                        Button("+") {
                            viewModel.depth += 1
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                    }
                }

                Button(action: { withAnimation(.spring()) {
                    alignment = alignment == .topLeading ? .leading : .topLeading
                }}) {
                    Text("Toggle alignment")
                }
                .buttonStyle(BorderedButtonStyle())
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.gray.opacity(0.1))
            )
            

//            ScrollView(.horizontal) {
            columnGraph()
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.green.opacity(0.15))
//            }
        }
        .onChange(of: viewModel.nodePositions, perform: { newValue in
            print("node pos counter \(newValue.count)")
            print("visible ndoes \(viewModel.visibleNodes.count)")
            if newValue.count == viewModel.visibleNodes.count {
                print("reloading edges")
                viewModel.reloadEdges()
            }
        })
        .onChange(of: viewModel.focusedNode) { newValue in
            print("focused node changed to \(newValue?.id ?? "")")
            viewModel.loadGraph()
            viewModel.reloadEdges()
        }
        .onChange(of: viewModel.depth) { newValue in
            print("depth changed to \(newValue)")
            viewModel.loadGraph()
            viewModel.reloadEdges()
        }
    }

    @ViewBuilder
    func columnGraph() -> some View {
        ZStack(alignment: alignment) {
            EdgesView(
                positions: $viewModel.nodePositions,
                edges: $viewModel.visibleEdges
            )
            
            ColumnGraphView(
                nodes: [viewModel.focusedNode].compactMap { $0 },
                depth: viewModel.depth,
                updatePos: { node, pos in
                    viewModel.nodePositions.removeAll(where: { $0.node == node })
                    if let pos {
                        viewModel.nodePositions.append(.init(node: node, position: pos))
                    }
                }
            )
        }
        .coordinateSpace(name: "Graph")
    }
}

struct ColumnGraphView: View {
    let nodes: [Node]
    let depth: Int
    let updatePos: ((Node, CGPoint?)) -> Void

    var body: some View {
        if depth > 0 {
            NodeGroupView(nodes: nodes, updatePos: updatePos)

            ColumnGraphView(
                nodes: nodes.flatMap(\.children).unique(),
                depth: depth - 1,
                updatePos: updatePos
            )
            .offset(x: 80)
        }
    }
}

struct NodeGroupView: View {
    let nodes: [Node]
    let updatePos: ((Node, CGPoint?)) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(nodes, id: \.id) { node in
                NodeView(node: node) { pos in
                    updatePos((node, pos))
                }
                .padding(.vertical, 16)
                .opacity(0.2)
            }
        }
    }
}

struct NodeView: View {
    let node: Node
    let updatePos: (CGPoint?) -> Void
    @State private var rect: CGRect = .zero

    init(node: Node, updatePos: @escaping (CGPoint?) -> Void) {
        self.node = node
        self.updatePos = updatePos
    }

    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .background(Color.white)
                    .padding(2)

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(lineWidth: 2)
                    .background(Color.white)
            }

            Text(node.id)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 50, maxHeight: 50)
        .trackPosition(binding: $rect)
        .onChange(of: rect, perform: { newValue in
            updatePos(CGPoint(x: newValue.midX, y: newValue.midY))
        })
        .onTapGesture {
            withAnimation(.spring()) {
                node.action?()
            }
        }
        .onDisappear { updatePos(nil) }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView(viewModel: GraphViewModel())
    }
}

extension Collection where Element: Hashable {
    func unique() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}

// Define a custom PreferenceKey
struct ViewPositionKey: PreferenceKey {
    typealias Value = CGRect

    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// Define a custom SwiftUI Modifier
struct ViewPositionModifier: ViewModifier {
    @Binding var position: CGRect

    func body(content: Content) -> some View {
        content
            .background(GeometryReader { proxy in
                Color.clear.preference(key: ViewPositionKey.self, value: proxy.frame(in: .named("Graph")))
            })
            .onPreferenceChange(ViewPositionKey.self) { position in
                guard self.position != position else { return }
                self.position = position
            }
    }
}

// Extension for View to easily use the modifier
extension View {
    func trackPosition(binding: Binding<CGRect>) -> some View {
        modifier(ViewPositionModifier(position: binding))
    }
}
