//
//  AsyncArgumentTests.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 19.12.2024.
//

import DependencyInjection
import Testing

@Suite("Container/Async/Arguments", .tags(.async, .arguments))
struct AsyncContainerArgumentTests {
    @Test("Registration with single argument")
    func registration() async {
        // Given
        let subject = AsyncContainer()
        await subject.register { _, argument -> DependencyWithValueTypeParameter in
            DependencyWithValueTypeParameter(subDependency: argument)
        }
        let argument = StructureDependency(property1: "48")

        // When
        let resolvedDependency: DependencyWithValueTypeParameter = await subject.resolve(argument: argument)

        // Then
        #expect(argument == resolvedDependency.subDependency)
    }

    @Test("Registration with explicit type")
    func registrationWithExplicitType() async {
        // Given
        let subject = AsyncContainer()
        await subject.register(type: DependencyWithValueTypeParameter.self) { _, argument in
            DependencyWithValueTypeParameter(subDependency: argument)
        }
        let argument = StructureDependency(property1: "48")

        // When
        let resolvedDependency: DependencyWithValueTypeParameter = await subject.resolve(argument: argument)

        // Then
        #expect(argument == resolvedDependency.subDependency)
    }

    @Test("Unmatching argument type - zero arguments")
    func unmatchingArgumentType_ZeroArguments() async throws {
        // Given
        let subject = AsyncContainer()
        await subject.register { _ -> SimpleDependency in
            SimpleDependency()
        }
        let argument = 48

        // When
        do {
            _ = try await subject.tryResolve(type: SimpleDependency.self, argument: argument)
            Issue.record("Expected to throw error")
        } catch {
            // Then
            guard let resolutionError = error as? ResolutionError else {
                Issue.record("Incorrect error type")
                return
            }

            switch resolutionError {
            case .unmatchingArgumentType:
                #expect(!resolutionError.localizedDescription.isEmpty)
            default:
                Issue.record("Incorrect resolution error")
            }
        }
    }

    @Test("Unmatching argument type - one argument")
    func unmatchingArgumentType_OneArgument() async throws {
        // Given
        let subject = AsyncContainer()
        await subject.register { _, argument -> DependencyWithValueTypeParameter in
            DependencyWithValueTypeParameter(subDependency: argument)
        }
        let argument = 48

        // When
        do {
            _ = try await subject.tryResolve(type: DependencyWithValueTypeParameter.self, argument: argument)
            Issue.record("Expected to throw error")
        } catch {
            // Then
            guard let resolutionError = error as? ResolutionError else {
                Issue.record("Incorrect error type")
                return
            }

            switch resolutionError {
            case .unmatchingArgumentType:
                #expect(!resolutionError.localizedDescription.isEmpty)
            default:
                Issue.record("Incorrect resolution error")
            }
        }
    }

    @Test("Registration with two arguments")
    func registrationWithTwoArguments() async {
        // Given
        let subject = AsyncContainer()
        await subject.register { _, argument1, argument2 -> DependencyWithTwoArguments in
            DependencyWithTwoArguments(argument1: argument1, argument2: argument2)
        }
        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"

        // When
        let resolvedDependency: DependencyWithTwoArguments = await subject.resolve(argument1: argument1, argument2: argument2)

        // Then
        #expect(argument1 == resolvedDependency.argument1)
        #expect(argument2 == resolvedDependency.argument2)
    }

    @Test("Registration with two arguments with explicit type")
    func registrationWithTwoArgumentsWithExplicitType() async {
        // Given
        let subject = AsyncContainer()
        await subject.register(type: DependencyWithTwoArguments.self) { _, argument1, argument2 in
            DependencyWithTwoArguments(argument1: argument1, argument2: argument2)
        }
        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"

        // When
        let resolvedDependency: DependencyWithTwoArguments = await subject.resolve(argument1: argument1, argument2: argument2)

        // Then
        #expect(argument1 == resolvedDependency.argument1)
        #expect(argument2 == resolvedDependency.argument2)
    }

    @Test("Unmatching argument type - two arguments")
    func unmatchingArgumentType_TwoArguments() async throws {
        // Given
        let subject = AsyncContainer()
        await subject.register { _, argument1, argument2 -> DependencyWithTwoArguments in
            DependencyWithTwoArguments(argument1: argument1, argument2: argument2)
        }
        let argument1 = 48
        let argument2 = "test"

        // When
        do {
            _ = try await subject.tryResolve(type: DependencyWithTwoArguments.self, argument1: argument1, argument2: argument2)
            Issue.record("Expected to throw error")
        } catch {
            // Then
            guard let resolutionError = error as? ResolutionError else {
                Issue.record("Incorrect error type")
                return
            }

            switch resolutionError {
            case .unmatchingArgumentType:
                #expect(!resolutionError.localizedDescription.isEmpty)
            default:
                Issue.record("Incorrect resolution error")
            }
        }
    }

    @Test("Registration with three arguments")
    func registrationWithThreeArguments() async {
        // Given
        let subject = AsyncContainer()
        await subject.register { _, argument1, argument2, argument3 -> DependencyWithThreeArguments in
            DependencyWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }
        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let argument3 = 42

        // When
        let resolvedDependency: DependencyWithThreeArguments = await subject.resolve(argument1: argument1, argument2: argument2, argument3: argument3)

        // Then
        #expect(argument1 == resolvedDependency.argument1)
        #expect(argument2 == resolvedDependency.argument2)
        #expect(argument3 == resolvedDependency.argument3)
    }

    @Test("Registration with three arguments with explicit type")
    func registrationWithThreeArgumentsWithExplicitType() async {
        // Given
        let subject = AsyncContainer()
        await subject.register(type: DependencyWithThreeArguments.self) { _, argument1, argument2, argument3 in
            DependencyWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }
        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let argument3 = 42

        // When
        let resolvedDependency: DependencyWithThreeArguments = await subject.resolve(argument1: argument1, argument2: argument2, argument3: argument3)

        // Then
        #expect(argument1 == resolvedDependency.argument1)
        #expect(argument2 == resolvedDependency.argument2)
        #expect(argument3 == resolvedDependency.argument3)
    }

    @Test("Unmatching argument type - three arguments")
    func unmatchingArgumentType_ThreeArguments() async throws {
        // Given
        let subject = AsyncContainer()
        await subject.register { _, argument1, argument2, argument3 -> DependencyWithThreeArguments in
            DependencyWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }
        let argument1 = 48
        let argument2 = "test"
        let argument3 = 42

        // When
        do {
            _ = try await subject.tryResolve(type: DependencyWithThreeArguments.self, argument1: argument1, argument2: argument2, argument3: argument3)
            Issue.record("Expected to throw error")
        } catch {
            // Then
            guard let resolutionError = error as? ResolutionError else {
                Issue.record("Incorrect error type")
                return
            }

            switch resolutionError {
            case .unmatchingArgumentType:
                #expect(!resolutionError.localizedDescription.isEmpty)
            default:
                Issue.record("Incorrect resolution error")
            }
        }
    }

    @Test("Registration with async initialization")
    func registrationWithAsyncInit() async {
        // Given
        let subject = AsyncContainer()
        await subject.register { _, argument -> DependencyWithAsyncInitWithParameter in
            await DependencyWithAsyncInitWithParameter(subDependency: argument)
        }
        let argument = StructureDependency(property1: "48")

        // When
        let resolvedDependency: DependencyWithAsyncInitWithParameter = await subject.resolve(argument: argument)

        // Then
        #expect(argument == resolvedDependency.subDependency)
    }

    @Test("Registration with async initialization and two arguments")
    func registrationWithAsyncInitWithTwoArguments() async {
        // Given
        let subject = AsyncContainer()
        await subject.register { _, argument1, argument2 -> DependencyWithAsyncInitWithTwoArguments in
            await DependencyWithAsyncInitWithTwoArguments(argument1: argument1, argument2: argument2)
        }
        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"

        // When
        let resolvedDependency: DependencyWithAsyncInitWithTwoArguments = await subject.resolve(argument1: argument1, argument2: argument2)

        // Then
        #expect(argument1 == resolvedDependency.argument1)
        #expect(argument2 == resolvedDependency.argument2)
    }

    @Test("Registration with async initialization and three arguments")
    func registrationWithAsyncInitWithThreeArguments() async {
        // Given
        let subject = AsyncContainer()
        await subject.register { _, argument1, argument2, argument3 -> DependencyWithAsyncInitWithThreeArguments in
            await DependencyWithAsyncInitWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }
        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let argument3 = 42

        // When
        let resolvedDependency: DependencyWithAsyncInitWithThreeArguments = await subject.resolve(argument1: argument1, argument2: argument2, argument3: argument3)

        // Then
        #expect(argument1 == resolvedDependency.argument1)
        #expect(argument2 == resolvedDependency.argument2)
        #expect(argument3 == resolvedDependency.argument3)
    }
}
