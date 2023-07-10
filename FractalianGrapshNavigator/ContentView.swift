//
//  ContentView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 10/07/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            GraphView(viewModel: .init())
                .navigationBarTitle("Fractalian Graph Navigator")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
