//
//  AsyncComplexTests.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 19.12.2024.
//

import DependencyInjection
import Testing

@Suite("Container/Async/Complex", .tags(.async, .complex))
struct AsyncComplexTests {
    @Test("Clean container")
    func cleanContainer() async throws {
        // Given
        let subject = AsyncContainer()
        await subject.register { _ in
            SimpleDependency()
        }

        // When
        let resolvedDependency = try? await subject.tryResolve(type: SimpleDependency.self)
        #expect(resolvedDependency != nil)

        await subject.clean()

        // Then
        let unresolvedDependency = try? await subject.tryResolve(type: SimpleDependency.self)
        #expect(unresolvedDependency == nil)
    }

    @Test("Release shared instances")
    func releaseSharedInstances() async {
        // Given
        let subject = AsyncContainer()
        await subject.register(in: .shared) { _ in
            SimpleDependency()
        }

        // When
        var resolvedDependency1: SimpleDependency? = await subject.resolve(type: SimpleDependency.self)
        weak var resolvedDependency2 = await subject.resolve(type: SimpleDependency.self)

        #expect(resolvedDependency1 != nil)
        #expect(resolvedDependency1 === resolvedDependency2)

        await subject.releaseSharedInstances()

        let resolvedDependency3 = await subject.resolve(type: SimpleDependency.self)

        // Then
        #expect(resolvedDependency1 !== resolvedDependency3)

        resolvedDependency1 = nil

        #expect(resolvedDependency2 == nil)
    }

    @Test("Reregistration")
    func reregistration() async {
        // Given
        let subject = AsyncContainer()
        await subject.register(type: DIProtocol.self, in: .shared) { _ in
            SimpleDependency()
        }

        // When
        let resolvedSimpleDependency = await subject.resolve(type: DIProtocol.self)

        // Then
        #expect(resolvedSimpleDependency is SimpleDependency)

        // When
        await subject.register(type: DIProtocol.self, in: .shared) { _ in
            StructureDependency.default
        }

        let resolvedStructureDependency = await subject.resolve(type: DIProtocol.self)

        // Then
        #expect(resolvedStructureDependency is StructureDependency)
    }

    @Test("Same dependency type registered with different types")
    func sameDependencyTypeRegisteredWithDifferentTypes() async {
        // Given
        let subject = AsyncContainer()
        await subject.register(type: DIProtocol.self, in: .shared) { _ in
            StructureDependency(property1: "first")
        }

        await subject.register(type: StructureDependency.self, in: .shared) { _ in
            StructureDependency(property1: "second")
        }

        // When
        let resolvedProtocolDependency: DIProtocol = await subject.resolve()
        let resolvedTypeDependency: StructureDependency = await subject.resolve()

        // Then
        #expect(resolvedProtocolDependency is StructureDependency)
        #expect(resolvedTypeDependency.property1 == "second")
        #expect((resolvedProtocolDependency as? StructureDependency)?.property1 != resolvedTypeDependency.property1)
    }

    @Test("Combining shared and non-shared dependencies")
    func combiningSharedAndNonsharedDependencies() async {
        // Given
        let subject = AsyncContainer()
        await subject.register(in: .new) { _ in
            SimpleDependency()
        }
        await subject.register(in: .shared) {
            DependencyWithParameter(subDependency: await $0.resolve())
        }
        await subject.register {
            DependencyWithParameter3(
                subDependency1: await $0.resolve(),
                subDependency2: $1,
                subDependency3: await $0.resolve()
            )
        }

        let argumentDependency1 = DependencyWithValueTypeParameter(
            subDependency: StructureDependency(property1: "first")
        )
        let argumentDependency2 = DependencyWithValueTypeParameter(
            subDependency: StructureDependency(property1: "second")
        )

        // When
        let resolvedDependency1: DependencyWithParameter = await subject.resolve()
        let resolvedDependency2: DependencyWithParameter = await subject.resolve()
        let resolvedDependency3 = await subject.resolve(type: DependencyWithParameter3.self, argument: argumentDependency1)
        let resolvedDependency4 = await subject.resolve(type: DependencyWithParameter3.self, argument: argumentDependency2)

        // Then
        #expect(resolvedDependency1 === resolvedDependency2)
        #expect(resolvedDependency1.subDependency === resolvedDependency2.subDependency)
        #expect(resolvedDependency1.subDependency !== resolvedDependency3.subDependency1)
        #expect(resolvedDependency3.subDependency1 !== resolvedDependency4.subDependency1)
        #expect(resolvedDependency3 !== resolvedDependency4)
        #expect(resolvedDependency3.subDependency2.subDependency.property1 != resolvedDependency4.subDependency2.subDependency.property1)
    }

    @Test("Combining shared and non-shared dependencies with explicit factories")
    func combiningSharedAndNonsharedDependenciesWithExplicitFactories() async {
        // Given
        let subject = AsyncContainer()
        await subject.register(in: .new) { _ in
            SimpleDependency()
        }
        await subject.register(in: .shared) {
            DependencyWithParameter(
                subDependency: await $0.resolve()
            )
        }
        await subject.register { resolver, argument in
            DependencyWithParameter3(
                subDependency1: await resolver.resolve(),
                subDependency2: argument,
                subDependency3: await resolver.resolve()
            )
        }

        let argumentDependency1 = DependencyWithValueTypeParameter(
            subDependency: StructureDependency(property1: "first")
        )
        let argumentDependency2 = DependencyWithValueTypeParameter(
            subDependency: StructureDependency(property1: "second")
        )

        // When
        let resolvedDependency1: DependencyWithParameter = await subject.resolve()
        let resolvedDependency2: DependencyWithParameter = await subject.resolve()
        let resolvedDependency3 = await subject.resolve(type: DependencyWithParameter3.self, argument: argumentDependency1)
        let resolvedDependency4 = await subject.resolve(type: DependencyWithParameter3.self, argument: argumentDependency2)

        // Then
        #expect(resolvedDependency1 === resolvedDependency2)
        #expect(resolvedDependency1.subDependency === resolvedDependency2.subDependency)
        #expect(resolvedDependency1.subDependency !== resolvedDependency3.subDependency1)
        #expect(resolvedDependency3.subDependency1 !== resolvedDependency4.subDependency1)
        #expect(resolvedDependency3 !== resolvedDependency4)
        #expect(resolvedDependency3.subDependency2.subDependency.property1 != resolvedDependency4.subDependency2.subDependency.property1)
    }
}
