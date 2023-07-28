//
//  LoadingView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 28/07/2023.
//

import SwiftUI

struct LoadingView: View {
    @Binding var isLoading: Bool
    
    var body: some View {
        if isLoading {
            ZStack {
                #if os(iOS)
                VisualEffect(style: .systemUltraThinMaterial)
                #elseif os(macOS)
                VisualEffect(style: .contentBackground)
                #endif
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(8)
            }
        }
    }
}
