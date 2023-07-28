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
    @Binding var disablePosUpdate: Bool
    @Binding var nodeSpacing: CGFloat
    @Binding var depthSpacing: CGFloat

    var loadGraph: () -> Void

    var body: some View {
        DynamicStack {
            Button("Graph Settings") {
                isPresentingGeneratePanel = true
            }
            .buttonStyle(MainButtonStyle())

            Button("Go to first node") {
                withAnimation {
                    focusedNode = nil
                }
            }
            .buttonStyle(SecondaryButtonStyle())

            if graphMode == .generated {
                Button("Generate new graph") {
                    loadGraph()
                }
                .buttonStyle(SecondaryButtonStyle())
            }

            HStack {
                Text("Graph Depth")
                    .font(.headline)
                    .foregroundColor(Color.white)

                Button {
                    withAnimation(.spring()) {
                        depth -= 1
                    }
                } label: {
                    Text("-")
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(SecondaryButtonStyle())

                Text("\(depth)")
                    .font(.title2)
                    .foregroundColor(Color.white)

                Button {
                    withAnimation(.spring()) {
                        depth += 1
                    }
                } label: {
                    Text("+")
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(MainButtonStyle())
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .sheet(isPresented: $isPresentingGeneratePanel) {
            ScrollView {
                makeFullPanel()
                    .padding(24)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    @ViewBuilder
    private func makeFullPanel() -> some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Graph settings")
                .font(.title3)

            VStack(alignment: .leading, spacing: 0) {
                Text("Graph input source")
                    .font(.caption)
                    .padding(.horizontal, 8)

                Picker("", selection: $graphMode.animation()) {
                    Text("File")
                        .tag(GraphMode.file)
                    Text("Generated")
                        .tag(GraphMode.generated)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            if graphMode == .generated {
                makeInputView("Number of nodes", $genNodesCount)
                makeInputView("Number of edges", $genEdgesCount)
            }

            makeInputView("Default depth", $defaultDepth)
            makeSliderView("Node spacing", $nodeSpacing, 4...200)
            makeSliderView("Depth spacing", $depthSpacing, 4...200)
            
            Toggle("Disable position update", isOn: $disablePosUpdate)
                .toggleStyle(SwitchToggleStyle(tint: Color.color3))
                .padding(.horizontal, 8)

            Button("Generate graph") {
                loadGraph()
                isPresentingGeneratePanel = false
            }
            .buttonStyle(MainButtonStyle())

            Spacer()
        }
    }

    @ViewBuilder
    private func makeInputView(_ title: String, _ text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 8)

            makeTextField(text)
        }
    }
    
    @ViewBuilder
    private func makeSliderView(_ title: String, _ value: Binding<CGFloat>, _ range: ClosedRange<CGFloat>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 8)

            HStack(spacing: 8) {
                Text("\(Int(range.lowerBound))")
                Slider(value: value.animation(.spring()), in: range)
                Text("\(Int(range.upperBound))")
            }
            .font(.footnote)
        }
    }

    @ViewBuilder
    private func makeTextField(_ text: Binding<String>) -> some View {
        #if os(iOS)
        TextField("", text: text)
            .keyboardType(.numberPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        #elseif os(macOS)
        TextField("", text: text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        #endif
    }
}
