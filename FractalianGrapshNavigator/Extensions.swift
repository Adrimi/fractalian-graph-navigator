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

public struct BlurEffectView: View {
    private let radius: CGFloat
//    private let invHorizontalPadding: CGFloat
//    private let invTopPadding: CGFloat
//    private let invBottomPadding: CGFloat

    public init(radius: CGFloat = 8) {
        self.radius = radius
//        invHorizontalPadding = -2 * radius
//        invTopPadding = -2 * radius
//        invBottomPadding = -3 * radius
    }
    
    public var body: some View {
        VisualEffect(style: .systemUltraThinMaterial)
//            .padding(.horizontal, invHorizontalPadding)
//            .padding(.top, invTopPadding)
//            .padding(.bottom, invBottomPadding)
            .blur(radius: radius)
            .ignoresSafeArea()
    }
}

public extension View {
    func blur(radius: CGFloat = 8) -> some View {
        background(BlurEffectView(radius: radius))
    }
}
