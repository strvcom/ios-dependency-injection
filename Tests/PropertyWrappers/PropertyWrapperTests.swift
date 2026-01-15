//
//  PropertyWrapperTests.swift
//
//
//  Created by Jan Schwarz on 28.03.2021.
//

import DependencyInjection
import Testing

@Suite("PropertyWrappers", .tags(.propertyWrappers))
struct PropertyWrapperTests {
    @Test("Injection with shared container")
    func injectionWithSharedContainer() {
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

    @Test("Injection with custom container")
    func injectionWithCustomContainer() {
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

    @Test("Lazy injection with shared container")
    func lazyInjectionWithSharedContainer() {
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

    @Test("Lazy injection with custom container")
    func lazyInjectionWithCustomContainer() {
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
