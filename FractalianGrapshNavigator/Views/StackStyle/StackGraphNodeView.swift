//
//  StackGraphNodeView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 30/07/2023.
//

import SwiftUI

struct StackGraphNodeView: View {
    enum Constants {
        static let spacing: CGFloat = 16
        static let cornerRadius: CGFloat = 8
        static let lineWidth: CGFloat = 2
        static let minimumScaleFactor: CGFloat = 0.5
        static let padding: CGFloat = 4
        static let aspectRatio: CGFloat = 1
        static let width: CGFloat = 50
        static let height: CGFloat = 50
    }

    let node: Node

    var body: some View {
        ZStack(alignment: .topLeading) {
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
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                        .fill(Color.color1)
                )
                .padding(Constants.padding)
        }
        .onTapGesture {
            withAnimation(.spring()) {
                node.action?()
            }
        }
    }
}
