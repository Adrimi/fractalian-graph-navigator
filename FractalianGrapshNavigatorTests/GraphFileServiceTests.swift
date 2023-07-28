//
//  GraphFileServiceTests.swift
//  GraphFileServiceTests
//
//  Created by Adrian Szymanowski on 10/07/2023.
//

@testable import FractalianGrapshNavigator
import XCTest

final class GraphFileServiceTests: XCTestCase {
    func testLoadGraphFromDefaultFile() async throws {
        let sut = makeSUT()
        do {
            let graph = try await sut.loadGraphFromDefaultFile()
            XCTAssertEqual(graph.nodes.count, 10)
            XCTAssertEqual(graph.edges.count, 13)
        } catch {
            XCTFail("Expected loadGraphFromDefaultFile to succeed, but it threw an error: \(error)")
        }
    }

    func testLoadGraphFromFileSuccess() async throws {
        let sut = makeSUT()
        do {
            let bundle = Bundle(for: type(of: self))
            let graph = try await sut.loadGraph(filename: "test_graph", in: bundle)
            XCTAssertEqual(graph.nodes.count, 9)
            XCTAssertEqual(graph.edges.count, 8)
        } catch {
            XCTFail("Expected loadGraphFromFile to succeed, but it threw an error: \(error)")
        }
    }

    func testLoadGraphFromFileNotFound() async throws {
        let sut = makeSUT()
        do {
            _ = try await sut.loadGraph(filename: "nonexistent")
            XCTFail("Expected loadGraphFromFile to throw GraphError.fileNotFound, but it did not.")
        } catch GraphError.fileNotFound {
            // Expected error, so test passes.
        } catch {
            XCTFail("Expected loadGraphFromFile to throw GraphError.fileNotFound, but it threw a different error: \(error)")
        }
    }

    func testLoadGraphFromFileInvalid() async throws {
        let sut = makeSUT()
        do {
            let bundle = Bundle(for: type(of: self))
            _ = try await sut.loadGraph(filename: "invalidGraph", in: bundle)
            XCTFail("Expected loadGraphFromFile to throw GraphError.invalidGraphMLFile, but it did not.")
        } catch GraphError.invalidGraphMLFile {
            // Expected error, so test passes.
        } catch {
            XCTFail("Expected loadGraphFromFile to throw GraphError.invalidGraphMLFile, but it threw a different error: \(error)")
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> GraphFileService {
        GraphFileService()
    }
}
