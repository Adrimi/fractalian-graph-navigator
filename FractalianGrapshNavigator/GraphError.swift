//
//  GraphError.swift
//  FractalianGrapshNavigator
//
//  Created by Adrian Szymanowski on 21/07/2023.
//

import Foundation

enum GraphError: Error {
    case fileNotFound
    case invalidGraphMLFile
    case notEnoughNodes
    case noNodeID
    case notANumber

    var message: String {
        switch self {
        case .fileNotFound: return "GraphML file not found"
        case .invalidGraphMLFile: return "Invalid GraphML file"
        case .notEnoughNodes: return "Need at least 2 nodes to generate edges."
        case .noNodeID: return "No node ID found"
        case .notANumber: return "Invalid number of nodes or edges"
        }
    }
}
