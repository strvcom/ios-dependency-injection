//
//  ArgumentTests.swift
//
//
//  Created by Jan Schwarz on 26.03.2021.
//

import DependencyInjection
import Testing

struct ContainerArgumentTests {
    @Test func registration() {
        // Given
        let subject = Container()
        subject.register { _, argument -> DependencyWithValueTypeParameter in
            DependencyWithValueTypeParameter(subDependency: argument)
        }
        let argument = StructureDependency(property1: "48")

        // When
        let resolvedDependency: DependencyWithValueTypeParameter = subject.resolve(argument: argument)

        // Then
        #expect(argument == resolvedDependency.subDependency)
    }

    @Test func registrationWithExplicitType() {
        // Given
        let subject = Container()
        subject.register(type: DependencyWithValueTypeParameter.self) { _, argument in
            DependencyWithValueTypeParameter(subDependency: argument)
        }
        let argument = StructureDependency(property1: "48")

        // When
        let resolvedDependency: DependencyWithValueTypeParameter = subject.resolve(argument: argument)

        // Then
        #expect(argument == resolvedDependency.subDependency)
    }

    @Test func unmatchingArgumentType() throws {
        // Given
        let subject = Container()
        subject.register { _, argument -> DependencyWithValueTypeParameter in
            DependencyWithValueTypeParameter(subDependency: argument)
        }
        let argument = 48

        // When
        do {
            _ = try subject.tryResolve(type: DependencyWithValueTypeParameter.self, argument: argument)
            Issue.record("Expected to throw error")
        } catch {
            // Then
            guard let resolutionError = error as? ResolutionError else {
                Issue.record("Incorrect error type")
                return
            }

            switch resolutionError {
            case .dependencyNotRegistered:
                #expect(!resolutionError.localizedDescription.isEmpty)
            default:
                Issue.record("Incorrect resolution error")
            }
        }
    }

    @Test func registrationWithTwoArguments() {
        // Given
        let subject = Container()
        subject.register { _, argument1, argument2 -> DependencyWithTwoArguments in
            DependencyWithTwoArguments(argument1: argument1, argument2: argument2)
        }
        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"

        // When
        let resolvedDependency: DependencyWithTwoArguments = subject.resolve(argument1: argument1, argument2: argument2)

        // Then
        #expect(argument1 == resolvedDependency.argument1)
        #expect(argument2 == resolvedDependency.argument2)
    }

    @Test func registrationWithTwoArgumentsWithExplicitType() {
        // Given
        let subject = Container()
        subject.register(type: DependencyWithTwoArguments.self) { _, argument1, argument2 in
            DependencyWithTwoArguments(argument1: argument1, argument2: argument2)
        }
        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"

        // When
        let resolvedDependency: DependencyWithTwoArguments = subject.resolve(argument1: argument1, argument2: argument2)

        // Then
        #expect(argument1 == resolvedDependency.argument1)
        #expect(argument2 == resolvedDependency.argument2)
    }

    @Test func unmatchingTwoArgumentsType() throws {
        // Given
        let subject = Container()
        subject.register { _, argument1, argument2 -> DependencyWithTwoArguments in
            DependencyWithTwoArguments(argument1: argument1, argument2: argument2)
        }
        let argument1 = 48
        let argument2 = "test"

        // When
        do {
            _ = try subject.tryResolve(type: DependencyWithTwoArguments.self, argument1: argument1, argument2: argument2)
            Issue.record("Expected to throw error")
        } catch {
            // Then
            guard let resolutionError = error as? ResolutionError else {
                Issue.record("Incorrect error type")
                return
            }

            switch resolutionError {
            case .dependencyNotRegistered:
                #expect(!resolutionError.localizedDescription.isEmpty)
            default:
                Issue.record("Incorrect resolution error")
            }
        }
    }

    @Test func registrationWithThreeArguments() {
        // Given
        let subject = Container()
        subject.register { _, argument1, argument2, argument3 -> DependencyWithThreeArguments in
            DependencyWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }
        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let argument3 = 42

        // When
        let resolvedDependency: DependencyWithThreeArguments = subject.resolve(argument1: argument1, argument2: argument2, argument3: argument3)

        // Then
        #expect(argument1 == resolvedDependency.argument1)
        #expect(argument2 == resolvedDependency.argument2)
        #expect(argument3 == resolvedDependency.argument3)
    }

    @Test func registrationWithThreeArgumentsWithExplicitType() {
        // Given
        let subject = Container()
        subject.register(type: DependencyWithThreeArguments.self) { _, argument1, argument2, argument3 in
            DependencyWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }
        let argument1 = StructureDependency(property1: "test1")
        let argument2 = "test2"
        let argument3 = 42

        // When
        let resolvedDependency: DependencyWithThreeArguments = subject.resolve(argument1: argument1, argument2: argument2, argument3: argument3)

        // Then
        #expect(argument1 == resolvedDependency.argument1)
        #expect(argument2 == resolvedDependency.argument2)
        #expect(argument3 == resolvedDependency.argument3)
    }

    @Test func unmatchingThreeArgumentsType() throws {
        // Given
        let subject = Container()
        subject.register { _, argument1, argument2, argument3 -> DependencyWithThreeArguments in
            DependencyWithThreeArguments(argument1: argument1, argument2: argument2, argument3: argument3)
        }
        let argument1 = 48
        let argument2 = "test"
        let argument3 = 42

        // When
        do {
            _ = try subject.tryResolve(type: DependencyWithThreeArguments.self, argument1: argument1, argument2: argument2, argument3: argument3)
            Issue.record("Expected to throw error")
        } catch {
            // Then
            guard let resolutionError = error as? ResolutionError else {
                Issue.record("Incorrect error type")
                return
            }

            switch resolutionError {
            case .dependencyNotRegistered:
                #expect(!resolutionError.localizedDescription.isEmpty)
            default:
                Issue.record("Incorrect resolution error")
            }
        }
    }
}
