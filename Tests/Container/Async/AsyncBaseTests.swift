//
//  AsyncBaseTests.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 19.12.2024.
//

import DependencyInjection
import XCTest

final class AsyncBaseTests: AsyncDITestCase {
    func testDependencyRegisteredInDefaultScope() async {
        await container.register { _ -> SimpleDependency in
            SimpleDependency()
        }

        let resolvedDependency1: SimpleDependency = await container.resolve()
        let resolvedDependency2: SimpleDependency = await container.resolve()

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Container returned different instance")
    }

    func testDependencyRegisteredInDefaultScopeWithExplicitType() async {
        await container.register(type: SimpleDependency.self) { _ -> SimpleDependency in
            SimpleDependency()
        }

        let resolvedDependency1: SimpleDependency = await container.resolve()
        let resolvedDependency2: SimpleDependency = await container.resolve()

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Container returned different instance")
    }

    func testSharedDependency() async {
        await container.register(in: .shared) { _ -> SimpleDependency in
            SimpleDependency()
        }

        let resolvedDependency1: SimpleDependency = await container.resolve()
        let resolvedDependency2: SimpleDependency = await container.resolve()

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Container returned different instance")
    }

    func testNonSharedDependency() async {
        await container.register(in: .new) { _ -> SimpleDependency in
            SimpleDependency()
        }

        let resolvedDependency1: SimpleDependency = await container.resolve()
        let resolvedDependency2: SimpleDependency = await container.resolve()

        XCTAssertTrue(resolvedDependency1 !== resolvedDependency2, "Container returned the same instance")
    }

    func testNonSharedDependencyWithExplicitType() async {
        await container.register(type: SimpleDependency.self, in: .new) { _ in
            SimpleDependency()
        }

        let resolvedDependency1: SimpleDependency = await container.resolve()
        let resolvedDependency2: SimpleDependency = await container.resolve()

        XCTAssertTrue(resolvedDependency1 !== resolvedDependency2, "Container returned the same instance")
    }

    func testUnregisteredDependency() async {
        do {
            _ = try await container.tryResolve(type: SimpleDependency.self)

            XCTFail("Expected to fail tryResolve")
        } catch {
            guard let resolutionError = error as? ResolutionError else {
                XCTFail("Incorrect error type")
                return
            }

            switch resolutionError {
            case .dependencyNotRegistered:
                XCTAssertNotEqual(resolutionError.localizedDescription, "", "Error description is empty")
            default:
                XCTFail("Incorrect resolution error")
            }
        }
    }
}
