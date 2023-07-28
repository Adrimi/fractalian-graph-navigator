//
//  NodeView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 18/07/2023.
//

import SwiftUI

struct NodeView: View {
    enum Constants {
        static let spacing: CGFloat = 16
        static let cornerRadius: CGFloat = 8
        static let lineWidth: CGFloat = 2
        static let minimumScaleFactor: CGFloat = 0.5
        static let padding: CGFloat = 2
        static let aspectRatio: CGFloat = 1
        static let width: CGFloat = 50
        static let height: CGFloat = 50
    }

    let node: Node
    let updatePos: (CGPoint) -> Void
    @State private var rect: CGRect = .zero

    init(node: Node, updatePos: @escaping (CGPoint) -> Void) {
        self.node = node
        self.updatePos = updatePos
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                .foregroundColor(Color.color3)
            RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                .stroke(lineWidth: Constants.lineWidth)
                .foregroundColor(Color.white)

            Text(node.id)
                .allowsTightening(true)
                .minimumScaleFactor(Constants.minimumScaleFactor)
                .font(.title)
                .foregroundColor(Color.white)
                .padding(Constants.padding)
        }
        .aspectRatio(Constants.aspectRatio, contentMode: .fit)
        .frame(width: Constants.width, height: Constants.height)
        .trackPosition(binding: $rect)
        .onChange(of: rect, perform: { newValue in
            DispatchQueue.main.async {
                updatePos(CGPoint(x: newValue.midX, y: newValue.midY))
            }
        })
        .onTapGesture {
            withAnimation(.spring()) {
                node.action?()
            }
        }
        .id(node.id)
    }
}

struct NodeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NodeView(node: Node(id: "1"), updatePos: { _ in })
                .environment(\.colorScheme, .dark)

            NodeView(node: Node(id: "1"), updatePos: { _ in })
                .environment(\.colorScheme, .light)
        }
        .padding()
    }
}
