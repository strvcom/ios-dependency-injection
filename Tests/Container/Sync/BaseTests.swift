//
//  BaseTests.swift
//
//
//  Created by Jan Schwarz on 25.03.2021.
//

import DependencyInjection
import Testing

struct BaseTests {
    @Test func autoclosureDependency() {
        // Given
        let subject = Container()
        let dependency = SimpleDependency()
        subject.register(dependency: dependency)

        // When
        let resolvedDependency: SimpleDependency = subject.resolve()

        // Then
        #expect(dependency === resolvedDependency)
    }

    @Test func autoclosureDependencyWithExplicitType() {
        // Given
        let subject = Container()
        let dependency = SimpleDependency()
        subject.register(type: SimpleDependency.self, dependency: dependency)

        // When
        let resolvedDependency: SimpleDependency = subject.resolve()

        // Then
        #expect(dependency === resolvedDependency)
    }

    @Test func repeatedlyResolvedAutoclosureDependency() {
        // Given
        let subject = Container()
        subject.register(dependency: SimpleDependency())

        // When
        let resolvedDependency1: SimpleDependency = subject.resolve()
        let resolvedDependency2: SimpleDependency = subject.resolve()

        // Then
        #expect(resolvedDependency1 === resolvedDependency2)
    }

    @Test func dependencyRegisteredInDefaultScope() {
        // Given
        let subject = Container()
        subject.register { _ -> SimpleDependency in
            SimpleDependency()
        }

        // When
        let resolvedDependency1: SimpleDependency = subject.resolve()
        let resolvedDependency2: SimpleDependency = subject.resolve()

        // Then
        #expect(resolvedDependency1 === resolvedDependency2)
    }

    @Test func dependencyRegisteredInDefaultScopeWithExplicitType() {
        // Given
        let subject = Container()
        subject.register(type: SimpleDependency.self) { _ -> SimpleDependency in
            SimpleDependency()
        }

        // When
        let resolvedDependency1: SimpleDependency = subject.resolve()
        let resolvedDependency2: SimpleDependency = subject.resolve()

        // Then
        #expect(resolvedDependency1 === resolvedDependency2)
    }

    @Test func sharedDependency() {
        // Given
        let subject = Container()
        subject.register(in: .shared) { _ -> SimpleDependency in
            SimpleDependency()
        }

        // When
        let resolvedDependency1: SimpleDependency = subject.resolve()
        let resolvedDependency2: SimpleDependency = subject.resolve()

        // Then
        #expect(resolvedDependency1 === resolvedDependency2)
    }

    @Test func nonSharedDependency() {
        // Given
        let subject = Container()
        subject.register(in: .new) { _ -> SimpleDependency in
            SimpleDependency()
        }

        // When
        let resolvedDependency1: SimpleDependency = subject.resolve()
        let resolvedDependency2: SimpleDependency = subject.resolve()

        // Then
        #expect(resolvedDependency1 !== resolvedDependency2)
    }

    @Test func nonSharedDependencyWithExplicitType() {
        // Given
        let subject = Container()
        subject.register(type: SimpleDependency.self, in: .new) { _ in
            SimpleDependency()
        }

        // When
        let resolvedDependency1: SimpleDependency = subject.resolve()
        let resolvedDependency2: SimpleDependency = subject.resolve()

        // Then
        #expect(resolvedDependency1 !== resolvedDependency2)
    }

    @Test func unregisteredDependency() throws {
        // Given
        let subject = Container()

        // When
        do {
            _ = try subject.tryResolve(type: SimpleDependency.self)
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
