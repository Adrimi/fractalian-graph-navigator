//
//  FractalianGrapshNavigatorTests.swift
//  FractalianGrapshNavigatorTests
//
//  Created by Adrian Szymanowski on 10/07/2023.
//

@testable import FractalianGrapshNavigator
import XCTest

final class FractalianGrapshNavigatorTests: XCTestCase {
    func test_loadingGraph_with2DeepLayer() throws {
        let sut = GraphViewModel()
        sut.depth = 2
        sut.focusedNode = Node(id: "A")

        sut.loadGraph("graph")
        let result = try XCTUnwrap(sut.focusedNode)

        XCTAssertEqual(result.id, "A")
        XCTAssertEqual(result.children.count, 2)
        XCTAssertEqual(result.children.map(\.id), ["B", "C"])
        XCTAssertEqual(result.children.first?.children.map { $0.id }, ["D", "E"])
    }

    func test_loadingGraph_with3DeepLayer() throws {
        let sut = GraphViewModel()
        sut.depth = 3
        sut.focusedNode = Node(id: "A")

        sut.loadGraph("graph")
        let result = try XCTUnwrap(sut.focusedNode)

        XCTAssertEqual(result.id, "A")
        XCTAssertEqual(result.children.count, 2)
        XCTAssertEqual(result.children.map(\.id), ["B", "C"])
        XCTAssertEqual(result.children.first?.children.map { $0.id }, ["D", "E"])
        XCTAssertEqual(result.children.first?.children.first?.children.map(\.id), ["H", "I"])
    }

    func test_loadingGraph_with4DeepLayer() throws {
        let sut = GraphViewModel()
        sut.depth = 4
        sut.focusedNode = Node(id: "A")

        sut.loadGraph("graph")
        let result = try XCTUnwrap(sut.focusedNode)

        XCTAssertEqual(result.id, "A")
        XCTAssertEqual(result.children.count, 2)
        XCTAssertEqual(result.children.map(\.id), ["B", "C"])
        XCTAssertEqual(result.children.first?.children.map { $0.id }, ["D", "E"])
        XCTAssertEqual(result.children.first?.children.first?.children.map(\.id), ["H", "I"])
        XCTAssertEqual(result.children.first?.children.first?.children.first?.children.map(\.id), ["J"])
    }
}
