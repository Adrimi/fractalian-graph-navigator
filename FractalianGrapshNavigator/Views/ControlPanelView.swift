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
    @Binding var graphStyle: GraphStyle
    @Binding var disablePosUpdate: Bool
    @Binding var nodeSpacing: CGFloat
    @Binding var depthSpacing: CGFloat

    var loadGraph: () -> Void

    var body: some View {
        DynamicStack {
            Button {
                isPresentingGeneratePanel = true
            } label: {
                Label("Settings", systemImage: "slider.horizontal.3")
            }
            .buttonStyle(MainButtonStyle())

            Button {
                withAnimation {
                    focusedNode = nil
                }
            } label: {
                Label("To Start", systemImage: "arrowshape.turn.up.backward")
            }
            .buttonStyle(SecondaryButtonStyle())

            if graphMode == .generated {
                Button {
                    loadGraph()
                } label: {
                    Label("New Graph", systemImage: "sparkles")
                }
                .buttonStyle(SecondaryButtonStyle())
            }

            makeDepthControl()
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
            Text("Settings")
                .font(.title3)

            VStack(alignment: .leading, spacing: 0) {
                Text("Input source")
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
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Display style")
                    .font(.caption)
                    .padding(.horizontal, 8)

                Picker("", selection: $graphStyle.animation()) {
                    Text("Column")
                        .tag(GraphStyle.column)
                    Text("Stack")
                        .tag(GraphStyle.stack)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            if graphMode == .generated {
                makeInputView("Number of nodes", $genNodesCount)
                makeInputView("Number of edges", $genEdgesCount)
            }

            makeInputView("Default depth", $defaultDepth)
            makeSliderView("Node spacing", $nodeSpacing, 4 ... 200)
            makeSliderView("Depth spacing", $depthSpacing, 4 ... 200)

            Toggle("Disable position update", isOn: $disablePosUpdate)
                .toggleStyle(SwitchToggleStyle(tint: Color.color3))
                .padding(.horizontal, 8)

            Button("Generate Graph!") {
                loadGraph()
                isPresentingGeneratePanel = false
            }
            .buttonStyle(MainButtonStyle())

            Spacer()
        }
    }

    @ViewBuilder
    private func makeDepthControl() -> some View {
        HStack {
            Text("Depth")
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
                Slider(value: value, in: range)
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
