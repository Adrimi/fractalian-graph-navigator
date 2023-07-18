//
//  ControlPanelView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 18/07/2023.
//

import SwiftUI

struct ControlPanelView: View {
    @ObservedObject var viewModel: GraphViewModel

    init(viewModel: GraphViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(alignment: .bottom) {
            VStack {
                Button("Graph Settings") {
                    viewModel.isPresentingGeneratePanel = true
                }
                .buttonStyle(BorderedProminentButtonStyle())

                Button("Go to first node") {
                    withAnimation(.spring()) {
                        viewModel.resetGraph()
                    }
                }
                .buttonStyle(BorderedButtonStyle())
                
                Button("Generate new graph") {
                    withAnimation(.spring()) {
                        viewModel.loadGraph()
                    }
                }
                .buttonStyle(BorderedButtonStyle())


                HStack {
                    Text("Graph Depth")
                        .font(.title3)

                    Button("-") {
                        withAnimation(.spring()) {
                            viewModel.depth -= 1
                        }
                    }
                    .buttonStyle(BorderedButtonStyle())

                    Text("\(viewModel.depth)")
                        .font(.title2)

                    Button("+") {
                        withAnimation(.spring()) {
                            viewModel.depth += 1
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
        .sheet(isPresented: $viewModel.isPresentingGeneratePanel) {
            VStack(alignment: .center, spacing: 16) {
                Text("Graph settings")
                    .font(.title)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Number of nodes")
                        .font(.caption)
                        .padding(.horizontal, 8)

                    #if os(iOS)
                    TextField("", text: $viewModel.genNodesCount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    #elseif os(macOS)
                    TextField("", text: $viewModel.genNodesCount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    #endif
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Number of edges")
                        .font(.caption)
                        .padding(.horizontal, 8)

                    #if os(iOS)
                    TextField("", text: $viewModel.genEdgesCount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    #elseif os(macOS)
                    TextField("", text: $viewModel.genEdgesCount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    #endif
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Graph input source")
                        .font(.caption)
                        .padding(.horizontal, 8)

                    Picker("", selection: $viewModel.graphMode) {
                        Text("File")
                            .tag(GraphViewModel.GraphMode.file)
                        Text("Generated")
                            .tag(GraphViewModel.GraphMode.generated)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Default depth")
                        .font(.caption)
                        .padding(.horizontal, 8)

                    #if os(iOS)
                    TextField("", text: $viewModel.defaultDepth)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    #elseif os(macOS)
                    TextField("", text: $viewModel.defaultDepth)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    #endif
                }

                Button("Generate graph") {
                    viewModel.loadGraph()
                    viewModel.isPresentingGeneratePanel = false
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
