//
//  EdgesView.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 14/07/2023.
//

import SwiftUI

struct EdgesView: View {
    @Binding var positions: [NodePosition]
    @Binding var edges: [Edge]
    let debug: Bool
    
    @State var edges2: [Edge] = []
    
    init(positions: Binding<[NodePosition]>, edges: Binding<[Edge]>, debug: Bool = false) {
        self._positions = positions
        self._edges = edges
        self.debug = debug
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if debug {
                ForEach(positions, id: \.self) { position in
                    Circle()
                        .frame(width: Constants.circleSize, height: Constants.circleSize)
                        .foregroundColor(Color.random().opacity(0.2))
                        .offset(x: position.position.x - Constants.circleSize / 2, y: position.position.y - Constants.circleSize / 2)
                }
            }
            
            ForEach(edges2, id: \.self) { edge in
                if let parentPoint = parentPosition(for: edge),
                   let childPoint = childPosition(for: edge) {
                    EdgeView(parentPoint: parentPoint, childPoint: childPoint)
                        .onAppear {
                            print("Edge \(edge.source) -> \(edge.target) appeared")
                        }
                        .onDisappear {
                            print("Edge \(edge.source) -> \(edge.target) disappeared")
                        }
                }
            }
        }
        .onChange(of: edges) { es in
            edges2 = es
        }
//        .onReceive(edges.publisher) { es in
//            edges2 = es
//        }
    }
    
    func parentPosition(for edge: Edge) -> CGPoint? {
        positions.first { $0.node.id == edge.source }?.position
    }
    
    func childPosition(for edge: Edge) -> CGPoint? {
        positions.first { $0.node.id == edge.target }?.position
    }
    
    enum Constants {
        static let circleSize: CGFloat = 20
    }
    
}

struct EdgeView: View {
    var parentPoint: CGPoint
    var childPoint: CGPoint

    var body: some View {
        GeometryReader { _ in
            Path { path in
                let from = CGPoint(x: parentPoint.x, y: parentPoint.y)
                let to = CGPoint(x: childPoint.x, y: childPoint.y)
                path.move(to: from)
                path.addLine(to: to)
            }
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .foregroundColor(Color.random())
        
        }
    }
}

struct EdgesView_Previews: PreviewProvider {
    static var nodesEdges: ([NodePosition], [Edge]) {
        let numc = 50
        let nodes = Array<NodePosition>.generateRandom(numc)
        let edges = Array<Edge>.generateRandomEdges(numc)
        return (nodes, edges)
    }
    
    static var previews: some View {
        EdgesView(
            positions: .constant(nodesEdges.0),
            edges: .constant(nodesEdges.1),
            debug: true
        )
        .frame(width: 250, height: 250)
        .padding(20)
        .background(Color.red.opacity(0.1))
    }
}

// random color extension
extension Color {
    static func random() -> Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

// generate any given number of Array<NodePosition>
// with a random XY point from 0 to 200
extension Array where Element == NodePosition {
    static func generateRandom(_ count: Int) -> [NodePosition] {
        var result: [NodePosition] = []
        for i in 0..<count {
            result.append(NodePosition(
                node: Node(id: "\(i)"),
                position: CGPoint(
                    x: Int.random(in: 00...230),
                    y: Int.random(in: 00...230)
                )))
        }
        return result
    }
}

// based on the Array<NodePosition> generate any given number of random Edges between any random NodePosition
extension Array where Element == Edge {
    static func generateRandomEdges(_ count: Int) -> [Edge] {
        var result: [Edge] = []
        
        var resultFailCounter = 10
        for _ in 0..<count {
        
            var failCounter = 10
            while resultFailCounter > 0 {
                let sourceID = Int.random(in: 0...count)
                var targetID = Int.random(in: 0...count)
                
                while sourceID == targetID && failCounter > 0 {
                    targetID = Int.random(in: 0...count)
                    failCounter -= 1
                }
                let edge = Edge(
                    source: "\(sourceID)",
                    target: "\(targetID)"
                )
                guard !result.contains(edge) else {
                    resultFailCounter -= 1
                    break
                }
                result.append(edge)
            }
            
        }
        
        print("Generated \(result.count) edges")
        
        return result
    }
}



