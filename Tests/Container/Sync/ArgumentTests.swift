//
//  ArgumentTests.swift
//
//
//  Created by Jan Schwarz on 26.03.2021.
//

import DependencyInjection
import XCTest

final class ContainerArgumentTests: DITestCase {
    func testRegistration() {
        container.register { _, argument -> DependencyWithValueTypeParameter in
            DependencyWithValueTypeParameter(subDependency: argument)
        }

        let argument = StructureDependency(property1: "48")
        let resolvedDependency: DependencyWithValueTypeParameter = container.resolve(argument: argument)

        XCTAssertEqual(argument, resolvedDependency.subDependency, "Container returned dependency with different argument")
    }

    func testRegistrationWithExplicitType() {
        container.register(type: DependencyWithValueTypeParameter.self) { _, argument in
            DependencyWithValueTypeParameter(subDependency: argument)
        }

        let argument = StructureDependency(property1: "48")
        let resolvedDependency: DependencyWithValueTypeParameter = container.resolve(argument: argument)

        XCTAssertEqual(argument, resolvedDependency.subDependency, "Container returned dependency with different argument")
    }

    func testUnmatchingArgumentType() {
        container.register { _, argument -> DependencyWithValueTypeParameter in
            DependencyWithValueTypeParameter(subDependency: argument)
        }

        let argument = 48

        XCTAssertThrowsError(
            try container.tryResolve(type: DependencyWithValueTypeParameter.self, argument: argument),
            "Resolver didn't throw an error"
        ) { error in
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

    func testRegistrationWithTwoArguments() {
        container.register { _, argument1, argument2 -> DependencyWithTwoArguments in
            DependencyWithTwoArguments(argument1: argument1, argument2: argument2)
        }

        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let resolvedDependency: DependencyWithTwoArguments = container.resolve(argument1: argument1, argument2: argument2)

        XCTAssertEqual(argument1, resolvedDependency.argument1, "Container returned dependency with different first argument")
        XCTAssertEqual(argument2, resolvedDependency.argument2, "Container returned dependency with different second argument")
    }

    func testRegistrationWithTwoArgumentsWithExplicitType() {
        container.register(type: DependencyWithTwoArguments.self) { _, argument1, argument2 in
            DependencyWithTwoArguments(argument1: argument1, argument2: argument2)
        }

        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let resolvedDependency: DependencyWithTwoArguments = container.resolve(argument1: argument1, argument2: argument2)

        XCTAssertEqual(argument1, resolvedDependency.argument1, "Container returned dependency with different first argument")
        XCTAssertEqual(argument2, resolvedDependency.argument2, "Container returned dependency with different second argument")
    }

    func testUnmatchingTwoArgumentsType() {
        container.register { _, argument1, argument2 -> DependencyWithTwoArguments in
            DependencyWithTwoArguments(argument1: argument1, argument2: argument2)
        }

        let argument1 = 48
        let argument2 = "test"

        XCTAssertThrowsError(
            try container.tryResolve(type: DependencyWithTwoArguments.self, argument1: argument1, argument2: argument2),
            "Resolver didn't throw an error"
        ) { error in
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

    func testRegistrationWithThreeArguments() {
        container.register { _, argument1, argument2, argument3 -> DependencyWithThreeArguments in
            DependencyWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }

        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let argument3 = 42
        let resolvedDependency: DependencyWithThreeArguments = container.resolve(argument1: argument1, argument2: argument2, argument3: argument3)

        XCTAssertEqual(argument1, resolvedDependency.argument1, "Container returned dependency with different first argument")
        XCTAssertEqual(argument2, resolvedDependency.argument2, "Container returned dependency with different second argument")
        XCTAssertEqual(argument3, resolvedDependency.argument3, "Container returned dependency with different third argument")
    }

    func testRegistrationWithThreeArgumentsWithExplicitType() {
        container.register(type: DependencyWithThreeArguments.self) { _, argument1, argument2, argument3 in
            DependencyWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }

        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let argument3 = 42
        let resolvedDependency: DependencyWithThreeArguments = container.resolve(argument1: argument1, argument2: argument2, argument3: argument3)

        XCTAssertEqual(argument1, resolvedDependency.argument1, "Container returned dependency with different first argument")
        XCTAssertEqual(argument2, resolvedDependency.argument2, "Container returned dependency with different second argument")
        XCTAssertEqual(argument3, resolvedDependency.argument3, "Container returned dependency with different third argument")
    }

    func testUnmatchingThreeArgumentsType() {
        container.register { _, argument1, argument2, argument3 -> DependencyWithThreeArguments in
            DependencyWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }

        let argument1 = 48
        let argument2 = "test"
        let argument3 = 42

        XCTAssertThrowsError(
            try container.tryResolve(type: DependencyWithThreeArguments.self, argument1: argument1, argument2: argument2, argument3: argument3),
            "Resolver didn't throw an error"
        ) { error in
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
