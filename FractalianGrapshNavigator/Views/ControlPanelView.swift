//
//  ControlPanelView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 18/07/2023.
//

import SwiftUI

struct ControlPanelView: View {
    @Binding var graph: Graph?
    @Binding var focusedNode: Node?
    @Binding var depth: Int
    @Binding var isPresentingGeneratePanel: Bool
    
    @Binding var genNodesCount: String
    @Binding var genEdgesCount: String
    @Binding var defaultDepth: String
    @Binding var graphMode: GraphMode
    
    var loadGraph: () -> Void
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack {
                Button("Graph Settings") {
                    isPresentingGeneratePanel = true
                }
                .buttonStyle(BorderedProminentButtonStyle())

                Button("Go to first node") {
                    withAnimation(.spring()) {
                        focusedNode = nil
                    }
                }
                .buttonStyle(BorderedButtonStyle())
                
                Button("Generate new graph") {
                    withAnimation(.spring()) {
                        loadGraph()
                    }
                }
                .buttonStyle(BorderedButtonStyle())


                HStack {
                    Text("Graph Depth")
                        .font(.title3)

                    Button("-") {
                        withAnimation(.spring()) {
                            depth -= 1
                        }
                    }
                    .buttonStyle(BorderedButtonStyle())

                    Text("\(depth)")
                        .font(.title2)

                    Button("+") {
                        withAnimation(.spring()) {
                            depth += 1
                        }
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.gray.opacity(0.1))
        )
        .sheet(isPresented: $isPresentingGeneratePanel) {
            VStack(alignment: .center, spacing: 16) {
                Text("Graph settings")
                    .font(.title)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Number of nodes")
                        .font(.caption)
                        .padding(.horizontal, 8)

                    #if os(iOS)
                    TextField("", text: $genNodesCount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    #elseif os(macOS)
                    TextField("", text: $genNodesCount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    #endif
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Number of edges")
                        .font(.caption)
                        .padding(.horizontal, 8)

                    #if os(iOS)
                    TextField("", text: $genEdgesCount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    #elseif os(macOS)
                    TextField("", text: $genEdgesCount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    #endif
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Graph input source")
                        .font(.caption)
                        .padding(.horizontal, 8)

                    Picker("", selection: $graphMode) {
                        Text("File")
                            .tag(GraphMode.file)
                        Text("Generated")
                            .tag(GraphMode.generated)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Default depth")
                        .font(.caption)
                        .padding(.horizontal, 8)

                    #if os(iOS)
                    TextField("", text: $defaultDepth)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    #elseif os(macOS)
                    TextField("", text: $defaultDepth)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    #endif
                }

                Button("Generate graph") {
                    loadGraph()
                    isPresentingGeneratePanel = false
                }
                .buttonStyle(BorderedProminentButtonStyle())

                Spacer()
            }
            .padding(24)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}
