//
//  AsyncBaseTests.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 19.12.2024.
//

import DependencyInjection
import Testing

@Suite("Container/Async/Base Registration", .tags(.async, .base))
struct AsyncBaseTests {
    @Test("Shared dependency")
    func sharedDependency() async {
        // Given
        let subject = AsyncContainer()
        await subject.register(in: .shared) { _ -> SimpleDependency in
            SimpleDependency()
        }

        // When
        let resolvedDependency1: SimpleDependency = await subject.resolve()
        let resolvedDependency2: SimpleDependency = await subject.resolve()

        // Then
        #expect(resolvedDependency1 === resolvedDependency2)
    }

    @Test("Non-shared dependency")
    func nonSharedDependency() async {
        // Given
        let subject = AsyncContainer()
        await subject.register(in: .new) { _ -> SimpleDependency in
            SimpleDependency()
        }

        // When
        let resolvedDependency1: SimpleDependency = await subject.resolve()
        let resolvedDependency2: SimpleDependency = await subject.resolve()

        // Then
        #expect(resolvedDependency1 !== resolvedDependency2)
    }

    @Test("Non-shared dependency with explicit type")
    func nonSharedDependencyWithExplicitType() async {
        // Given
        let subject = AsyncContainer()
        await subject.register(type: SimpleDependency.self, in: .new) { _ in
            SimpleDependency()
        }

        // When
        let resolvedDependency1: SimpleDependency = await subject.resolve()
        let resolvedDependency2: SimpleDependency = await subject.resolve()

        // Then
        #expect(resolvedDependency1 !== resolvedDependency2)
    }

    @Test("Unregistered dependency")
    func unregisteredDependency() async throws {
        // Given
        let subject = AsyncContainer()

        // When
        do {
            _ = try await subject.tryResolve(type: SimpleDependency.self)
            Issue.record("Expected to fail tryResolve")
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
