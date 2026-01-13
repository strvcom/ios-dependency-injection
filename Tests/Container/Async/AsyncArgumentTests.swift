//
//  AsyncArgumentTests.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 19.12.2024.
//

import DependencyInjection
import XCTest

final class AsyncContainerArgumentTests: AsyncDITestCase {
    func testRegistration() async {
        await container.register { _, argument -> DependencyWithValueTypeParameter in
            DependencyWithValueTypeParameter(subDependency: argument)
        }

        let argument = StructureDependency(property1: "48")
        let resolvedDependency: DependencyWithValueTypeParameter = await container.resolve(argument: argument)

        XCTAssertEqual(argument, resolvedDependency.subDependency, "Container returned dependency with different argument")
    }

    func testRegistrationWithExplicitType() async {
        await container.register(type: DependencyWithValueTypeParameter.self) { _, argument in
            DependencyWithValueTypeParameter(subDependency: argument)
        }

        let argument = StructureDependency(property1: "48")
        let resolvedDependency: DependencyWithValueTypeParameter = await container.resolve(argument: argument)

        XCTAssertEqual(argument, resolvedDependency.subDependency, "Container returned dependency with different argument")
    }

    func testUnmatchingArgumentType() async {
        await container.register { _, argument -> DependencyWithValueTypeParameter in
            DependencyWithValueTypeParameter(subDependency: argument)
        }

        let argument = 48

        do {
            _ = try await container.tryResolve(type: DependencyWithValueTypeParameter.self, argument: argument)

            XCTFail("Expected to throw error")
        } catch {
            guard let resolutionError = error as? ResolutionError else {
                XCTFail("Incorrect error type")
                return
            }

            switch resolutionError {
            case .unmatchingArgumentType:
                XCTAssertNotEqual(resolutionError.localizedDescription, "", "Error description is empty")
            default:
                XCTFail("Incorrect resolution error")
            }
        }
    }

    func testRegistrationWithAsyncInit() async {
        await container.register { _, argument -> DependencyWithAsyncInitWithParameter in
            await DependencyWithAsyncInitWithParameter(subDependency: argument)
        }

        let argument = StructureDependency(property1: "48")
        let resolvedDependency: DependencyWithAsyncInitWithParameter = await container.resolve(argument: argument)

        XCTAssertEqual(argument, resolvedDependency.subDependency, "Container returned dependency with different argument")
    }
}
