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
    func item(at index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
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
            .onPreferenceChange(ViewPositionKey.self) { newPosition in
                let intPosition = newPosition.integral
                guard self.position != intPosition else { return }
                self.position = intPosition
            }
    }
}

// Extension for View to easily use the modifier
extension View {
    func trackPosition(binding: Binding<CGRect>) -> some View {
        modifier(ViewPositionModifier(position: binding))
    }
}

#if os(iOS)
public struct VisualEffect: UIViewRepresentable {
    @State var style: UIBlurEffect.Style
    
    public init(style: UIBlurEffect.Style) {
        self.style = style
    }
    
    public func makeUIView(context _: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    public func updateUIView(_: UIVisualEffectView, context _: Context) {}
}
#elseif os(macOS)
public struct VisualEffect: NSViewRepresentable {
    @State var style: NSVisualEffectView.Material
    
    public init(style: NSVisualEffectView.Material) {
        self.style = style
    }
    
    public func makeNSView(context _: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = style
        return view
    }

    public func updateNSView(_: NSVisualEffectView, context _: Context) {}
}
#endif


extension Binding where Value == String {
    var asCGFloat: Binding<CGFloat> {
        .init(
            get: { CGFloat(Double(wrappedValue) ?? 0) },
            set: { wrappedValue = "\($0)" }
        )
    }
}
