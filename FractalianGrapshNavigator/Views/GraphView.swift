//
//  GraphView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 28/07/2023.
//

import SwiftUI

struct GraphView: View {
    @Binding var graphStyle: GraphStyle
    @Binding var nodePositions: [NodePosition]
    @Binding var visibleEdges: [Edge]
    @Binding var disablePosUpdate: Bool
    @Binding var focusedNode: Node?
    @Binding var depthSpacing: CGFloat
    @Binding var nodeSpacing: CGFloat
    @Binding var depth: Int
    @Binding var isLoading: Bool
    var geometry: Namespace.ID
    
    private let maxZoom = 0.2
    private let minZoom = 2.0
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0

    var doubleTapResetGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.spring()) {
                    totalZoom = 1.0
                }
            }
    }

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

    var body: some View {
        ZStack {
            Color.color2
            
            switch graphStyle {
            case .column:
                makeColumnGraph()
            case .stack:
                makeStackGraph()
            }

            LoadingView(isLoading: $isLoading)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .padding(.horizontal, 16)
        .shadow(radius: 16, x: 4, y: 4)
    }
    
    private func makeStackGraph() -> some View {
        StackGraphView(
            focusedNode: $focusedNode,
            nodeSpacing: $nodeSpacing,
            depth: depth
        )
    }
    
    private func makeColumnGraph() -> some View {
        ScrollViewReader { proxy in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ColumnGraphView(
                    nodePositions: $nodePositions,
                    visibleEdges: $visibleEdges,
                    disablePosUpdate: $disablePosUpdate,
                    focusedNode: $focusedNode,
                    depthSpacing: $depthSpacing,
                    nodeSpacing: $nodeSpacing,
                    depth: depth,
                    namespace: geometry
                )
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
    }
}
