//
//  ComplexTests.swift
//
//
//  Created by Jan Schwarz on 04.01.2022.
//

import DependencyInjection
import Testing

struct ComplexTests {
    @Test func cleanContainer() throws {
        // Given
        let subject = Container()
        subject.autoregister(initializer: SimpleDependency.init)

        // When
        let resolvedDependency = try? subject.tryResolve(type: SimpleDependency.self)
        #expect(resolvedDependency != nil)

        subject.clean()

        // Then
        let unresolvedDependency = try? subject.tryResolve(type: SimpleDependency.self)
        #expect(unresolvedDependency == nil)
    }

    @Test func releaseSharedInstances() {
        // Given
        let subject = Container()
        subject.autoregister(in: .shared, initializer: SimpleDependency.init)

        // When
        var resolvedDependency1: SimpleDependency? = subject.resolve(type: SimpleDependency.self)
        weak var resolvedDependency2 = subject.resolve(type: SimpleDependency.self)

        #expect(resolvedDependency1 != nil)
        #expect(resolvedDependency1 === resolvedDependency2)

        subject.releaseSharedInstances()

        let resolvedDependency3 = subject.resolve(type: SimpleDependency.self)

        // Then
        #expect(resolvedDependency1 !== resolvedDependency3)

        resolvedDependency1 = nil

        #expect(resolvedDependency2 == nil)
    }

    @Test func reregistration() {
        // Given
        let subject = Container()
        subject.register(type: DIProtocol.self, in: .shared) { _ in
            SimpleDependency()
        }

        // When
        let resolvedSimpleDependency = subject.resolve(type: DIProtocol.self)

        // Then
        #expect(resolvedSimpleDependency is SimpleDependency)

        // When
        subject.register(type: DIProtocol.self, in: .shared) { _ in
            StructureDependency.default
        }

        let resolvedStructureDependency = subject.resolve(type: DIProtocol.self)

        // Then
        #expect(resolvedStructureDependency is StructureDependency)
    }

    @Test func sameDependencyTypeRegisteredWithDifferentTypes() {
        // Given
        let subject = Container()
        subject.register(type: DIProtocol.self, in: .shared) { _ in
            StructureDependency(property1: "first")
        }

        subject.register(type: StructureDependency.self, in: .shared) { _ in
            StructureDependency(property1: "second")
        }

        // When
        let resolvedProtocolDependency: DIProtocol = subject.resolve()
        let resolvedTypeDependency: StructureDependency = subject.resolve()

        // Then
        #expect(resolvedProtocolDependency is StructureDependency)
        #expect(resolvedTypeDependency.property1 == "second")
        #expect((resolvedProtocolDependency as? StructureDependency)?.property1 != resolvedTypeDependency.property1)
    }

    @Test func combiningSharedAndNonsharedDependencies() {
        // Given
        let subject = Container()
        subject.autoregister(in: .new, initializer: SimpleDependency.init)
        subject.autoregister(in: .shared, initializer: DependencyWithParameter.init)
        subject.autoregister(argument: DependencyWithValueTypeParameter.self, initializer: DependencyWithParameter3.init)

        let argumentDependency1 = DependencyWithValueTypeParameter(
            subDependency: StructureDependency(property1: "first")
        )
        let argumentDependency2 = DependencyWithValueTypeParameter(
            subDependency: StructureDependency(property1: "second")
        )

        // When
        let resolvedDependency1: DependencyWithParameter = subject.resolve()
        let resolvedDependency2: DependencyWithParameter = subject.resolve()
        let resolvedDependency3 = subject.resolve(type: DependencyWithParameter3.self, argument: argumentDependency1)
        let resolvedDependency4 = subject.resolve(type: DependencyWithParameter3.self, argument: argumentDependency2)

        // Then
        #expect(resolvedDependency1 === resolvedDependency2)
        #expect(resolvedDependency1.subDependency === resolvedDependency2.subDependency)
        #expect(resolvedDependency1.subDependency !== resolvedDependency3.subDependency1)
        #expect(resolvedDependency3.subDependency1 !== resolvedDependency4.subDependency1)
        #expect(resolvedDependency3 !== resolvedDependency4)
        #expect(resolvedDependency3.subDependency2.subDependency.property1 != resolvedDependency4.subDependency2.subDependency.property1)
    }

    @Test func combiningSharedAndNonsharedDependenciesWithExplicitFactories() {
        // Given
        let subject = Container()
        subject.register(in: .new) { _ in
            SimpleDependency()
        }
        subject.register(in: .shared) { resolver in
            DependencyWithParameter(
                subDependency: resolver.resolve()
            )
        }
        subject.register { resolver, argument in
            DependencyWithParameter3(
                subDependency1: resolver.resolve(),
                subDependency2: argument,
                subDependency3: resolver.resolve()
            )
        }

        let argumentDependency1 = DependencyWithValueTypeParameter(
            subDependency: StructureDependency(property1: "first")
        )
        let argumentDependency2 = DependencyWithValueTypeParameter(
            subDependency: StructureDependency(property1: "second")
        )

        // When
        let resolvedDependency1: DependencyWithParameter = subject.resolve()
        let resolvedDependency2: DependencyWithParameter = subject.resolve()
        let resolvedDependency3 = subject.resolve(type: DependencyWithParameter3.self, argument: argumentDependency1)
        let resolvedDependency4 = subject.resolve(type: DependencyWithParameter3.self, argument: argumentDependency2)

        // Then
        #expect(resolvedDependency1 === resolvedDependency2)
        #expect(resolvedDependency1.subDependency === resolvedDependency2.subDependency)
        #expect(resolvedDependency1.subDependency !== resolvedDependency3.subDependency1)
        #expect(resolvedDependency3.subDependency1 !== resolvedDependency4.subDependency1)
        #expect(resolvedDependency3 !== resolvedDependency4)
        #expect(resolvedDependency3.subDependency2.subDependency.property1 != resolvedDependency4.subDependency2.subDependency.property1)
    }
}
