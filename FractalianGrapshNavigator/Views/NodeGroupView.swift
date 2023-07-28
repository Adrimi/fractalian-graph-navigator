//
//  NodeGroupView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 18/07/2023.
//

import SwiftUI

struct NodeGroupView: View {
    let nodes: [Node]
    let updatePos: (NodePosition) -> Void
    @Binding var nodeSpacing: CGFloat
    var namespace: Namespace.ID

    var body: some View {
        VStack(alignment: .center, spacing: nodeSpacing) {
            ForEach(nodes, id: \.id) { node in
                NodeView(node: node, namespace: namespace) { newPosition in
                    updatePos(NodePosition(node: node, position: newPosition))
                }
            }
        }
    }
}

//preview
struct NodeGroupView_Previews: PreviewProvider {
    static var previews: some View {
        NodeGroupView(nodes: [
            .init(id: "1"),
            .init(id: "2"),
            .init(id: "3")
        ], updatePos: { _ in }, nodeSpacing: .constant(8), namespace: Namespace().wrappedValue)
        .padding(8)
        .background(Color.red)
    }
}

