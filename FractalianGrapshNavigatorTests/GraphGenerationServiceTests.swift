//
//  GraphGenerationServiceTests.swift
//  FractalianGrapshNavigatorTests
//
//  Created by Adrian Szymanowski on 28/07/2023.
//

import Foundation
@testable import FractalianGrapshNavigator
import XCTest

final class GraphGenerationServiceTests: XCTestCase {
    func testGenerateGraphWithValidParameters() async throws {
        let sut = makeSUT()
        let numberOfNodes = 5
        let numberOfEdges = 4
        do {
            let graph = try await sut.generateGraph(numberOfNodes: numberOfNodes, numberOfEdges: numberOfEdges)
            XCTAssertEqual(graph.nodes.count, numberOfNodes, "The number of nodes in the graph should equal the number of nodes parameter.")
            XCTAssertEqual(graph.edges.count, numberOfEdges, "The number of edges in the graph should equal the number of edges parameter.")
        } catch {
            XCTFail("Expected generateGraph to succeed, but it threw an error: \(error)")
        }
    }

    func testGenerateGraphWithNotEnoughNodes() async throws {
        let sut = makeSUT()
        let numberOfNodes = 1
        let numberOfEdges = 4
        do {
            _ = try await sut.generateGraph(numberOfNodes: numberOfNodes, numberOfEdges: numberOfEdges)
            XCTFail("Expected generateGraph to throw GraphError.notEnoughNodes, but it did not.")
        } catch GraphError.notEnoughNodes {
            // Expected error, so test passes.
        } catch {
            XCTFail("Expected generateGraph to throw GraphError.notEnoughNodes, but it threw a different error: \(error)")
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> GraphGenerationService {
        GraphGenerationService()
    }
}
