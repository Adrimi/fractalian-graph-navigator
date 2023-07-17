//
//  Extensions.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 16/07/2023.
//

import SwiftUI

extension Collection {
    func printing(_ handler: (Element) -> Void) -> [Element] {
        map { handler($0); return $0 }
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
                Color.clear.preference(
                    key: ViewPositionKey.self,
                    value: proxy.frame(in: .named("Graph"))
                )
            })
            .onPreferenceChange(ViewPositionKey.self) { position in
//                guard self.position != position else { return }
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
