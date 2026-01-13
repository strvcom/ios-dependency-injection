//
//  PropertyWrapperTests.swift
//
//
//  Created by Jan Schwarz on 28.03.2021.
//

import DependencyInjection
import Testing

struct PropertyWrapperTests {
    @Test func injectionWithSharedContainer() {
        // Given
        struct Module {
            @Injected var resolvedDependency: SimpleDependency
        }

        let dependency = SimpleDependency()
        Container.shared.register(dependency: dependency)

        // When
        let module = Module()

        // Then
        #expect(dependency === module.resolvedDependency)

        // Cleanup
        Container.shared.clean()
    }

    @Test func injectionWithCustomContainer() {
        // Given
        let subject = Container()
        struct Module {
            static var container: Container!

            @Injected(from: container) var resolvedDependency: SimpleDependency
        }

        let dependency = SimpleDependency()
        subject.register(dependency: dependency)

        Module.container = subject

        // When
        let module = Module()

        // Then
        #expect(dependency === module.resolvedDependency)
    }

    @Test func lazyInjectionWithSharedContainer() {
        // Given
        struct Module {
            @LazyInjected var resolvedDependency: SimpleDependency
        }

        // When
        let module = Module()

        // Then
        let dependency = SimpleDependency()
        Container.shared.register(dependency: dependency)

        #expect(dependency === module.resolvedDependency)

        // Cleanup
        Container.shared.clean()
    }

    @Test func lazyInjectionWithCustomContainer() {
        // Given
        let subject = Container()
        struct Module {
            static var container: Container!

            @LazyInjected(from: container) var resolvedDependency: SimpleDependency
        }

        Module.container = subject

        // When
        let module = Module()

        // Then
        let dependency = SimpleDependency()
        subject.register(dependency: dependency)

        #expect(dependency === module.resolvedDependency)
    }
}
