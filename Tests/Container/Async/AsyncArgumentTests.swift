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

    func testUnmatchingArgumentType_ZeroArguments() async {
        await container.register { _ -> SimpleDependency in
            SimpleDependency()
        }

        let argument = 48

        do {
            _ = try await container.tryResolve(type: SimpleDependency.self, argument: argument)

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
                XCTFail("Incorrect resolution error: \(resolutionError)")
            }
        }
    }

    func testUnmatchingArgumentType_OneArgument() async {
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
                XCTFail("Incorrect resolution error: \(resolutionError)")
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

    func testRegistrationWithTwoArguments() async {
        await container.register { _, argument1, argument2 -> DependencyWithTwoArguments in
            DependencyWithTwoArguments(argument1: argument1, argument2: argument2)
        }

        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let resolvedDependency: DependencyWithTwoArguments = await container.resolve(argument1: argument1, argument2: argument2)

        XCTAssertEqual(argument1, resolvedDependency.argument1, "Container returned dependency with different first argument")
        XCTAssertEqual(argument2, resolvedDependency.argument2, "Container returned dependency with different second argument")
    }

    func testRegistrationWithTwoArgumentsWithExplicitType() async {
        await container.register(type: DependencyWithTwoArguments.self) { _, argument1, argument2 in
            DependencyWithTwoArguments(argument1: argument1, argument2: argument2)
        }

        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let resolvedDependency: DependencyWithTwoArguments = await container.resolve(argument1: argument1, argument2: argument2)

        XCTAssertEqual(argument1, resolvedDependency.argument1, "Container returned dependency with different first argument")
        XCTAssertEqual(argument2, resolvedDependency.argument2, "Container returned dependency with different second argument")
    }

    func testUnmatchingArgumentType_TwoArguments() async {
        await container.register { _, argument1, argument2 -> DependencyWithTwoArguments in
            DependencyWithTwoArguments(argument1: argument1, argument2: argument2)
        }

        let argument1 = 48
        let argument2 = "test"

        do {
            _ = try await container.tryResolve(type: DependencyWithTwoArguments.self, argument1: argument1, argument2: argument2)

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
                XCTFail("Incorrect resolution error: \(resolutionError)")
            }
        }
    }

    func testRegistrationWithThreeArguments() async {
        await container.register { _, argument1, argument2, argument3 -> DependencyWithThreeArguments in
            DependencyWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }

        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let argument3 = 42
        let resolvedDependency: DependencyWithThreeArguments = await container.resolve(argument1: argument1, argument2: argument2, argument3: argument3)

        XCTAssertEqual(argument1, resolvedDependency.argument1, "Container returned dependency with different first argument")
        XCTAssertEqual(argument2, resolvedDependency.argument2, "Container returned dependency with different second argument")
        XCTAssertEqual(argument3, resolvedDependency.argument3, "Container returned dependency with different third argument")
    }

    func testRegistrationWithThreeArgumentsWithExplicitType() async {
        await container.register(type: DependencyWithThreeArguments.self) { _, argument1, argument2, argument3 in
            DependencyWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }

        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let argument3 = 42
        let resolvedDependency: DependencyWithThreeArguments = await container.resolve(argument1: argument1, argument2: argument2, argument3: argument3)

        XCTAssertEqual(argument1, resolvedDependency.argument1, "Container returned dependency with different first argument")
        XCTAssertEqual(argument2, resolvedDependency.argument2, "Container returned dependency with different second argument")
        XCTAssertEqual(argument3, resolvedDependency.argument3, "Container returned dependency with different third argument")
    }

    func testUnmatchingArgumentType_ThreeArguments() async {
        await container.register { _, argument1, argument2, argument3 -> DependencyWithThreeArguments in
            DependencyWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }

        let argument1 = 48
        let argument2 = "test"
        let argument3 = 42

        do {
            _ = try await container.tryResolve(type: DependencyWithThreeArguments.self, argument1: argument1, argument2: argument2, argument3: argument3)

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
                XCTFail("Incorrect resolution error: \(resolutionError)")
            }
        }
    }

    func testRegistrationWithAsyncInitWithTwoArguments() async {
        await container.register { _, argument1, argument2 -> DependencyWithAsyncInitWithTwoArguments in
            await DependencyWithAsyncInitWithTwoArguments(argument1: argument1, argument2: argument2)
        }

        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let resolvedDependency: DependencyWithAsyncInitWithTwoArguments = await container.resolve(argument1: argument1, argument2: argument2)

        XCTAssertEqual(argument1, resolvedDependency.argument1, "Container returned dependency with different first argument")
        XCTAssertEqual(argument2, resolvedDependency.argument2, "Container returned dependency with different second argument")
    }

    func testRegistrationWithAsyncInitWithThreeArguments() async {
        await container.register { _, argument1, argument2, argument3 -> DependencyWithAsyncInitWithThreeArguments in
            await DependencyWithAsyncInitWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }

        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let argument3 = 42
        let resolvedDependency: DependencyWithAsyncInitWithThreeArguments = await container.resolve(argument1: argument1, argument2: argument2, argument3: argument3)

        XCTAssertEqual(argument1, resolvedDependency.argument1, "Container returned dependency with different first argument")
        XCTAssertEqual(argument2, resolvedDependency.argument2, "Container returned dependency with different second argument")
        XCTAssertEqual(argument3, resolvedDependency.argument3, "Container returned dependency with different third argument")
    }
}
