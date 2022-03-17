//
//  ComplexTests.swift
//  
//
//  Created by Jan Schwarz on 04.01.2022.
//

import XCTest
import DependencyInjectionModule

final class ComplexTests: DITestCase {
    func testCleanContainer() {
        container.autoregister(initializer: SimpleDependency.init)
        
        let resolvedDependency = try? container.tryResolve(type: SimpleDependency.self)
        
        XCTAssertNotNil(resolvedDependency, "Couldn't resolve dependency")
        
        container.clean()
        
        let unresolvedDependency = try? container.tryResolve(type: SimpleDependency.self)
        
        XCTAssertNil(unresolvedDependency, "Dependency wasn't cleaned")
    }
    
    func testReregistration() {
        container.register(type: DIProtocol.self, in: .shared) { _ in
            SimpleDependency()
        }
        
        let resolvedSimpleDependency = container.resolve(type: DIProtocol.self)
        
        XCTAssertTrue(resolvedSimpleDependency is SimpleDependency, "Resolved dependency of wrong type")
        
        container.register(type: DIProtocol.self, in: .shared) { _ in
            StructureDependency.default
        }
        
        let resolvedStructureDependency = container.resolve(type: DIProtocol.self)

        XCTAssertTrue(resolvedStructureDependency is StructureDependency, "Resolved dependency of wrong type")
    }
    
    func testSameDependencyTypeRegisteredWithDifferentTypes() {
        container.register(type: DIProtocol.self, in: .shared) { _ in
            StructureDependency(property1: "first")
        }
        
        container.register(type: StructureDependency.self, in: .shared) { _ in
            StructureDependency(property1: "second")
        }
        
        let resolvedProtocolDependency: DIProtocol = container.resolve()
        let resolvedTypeDependency: StructureDependency = container.resolve()
        
        XCTAssertTrue(resolvedProtocolDependency is StructureDependency, "Resolved dependency of wrong type")
        XCTAssertEqual(resolvedTypeDependency.property1, "second", "Resolved dependency from a wrong factory")

        XCTAssertNotEqual(
            (resolvedProtocolDependency as? StructureDependency)?.property1,
            resolvedTypeDependency.property1,
            "Resolved same instances"
        )
    }
    
    func testCombiningSharedAndNonsharedDependencies() {
        container.autoregister(in: .new, initializer: SimpleDependency.init)
        container.autoregister(in: .shared, initializer: DependencyWithParameter.init)
        container.autoregister(argument: DependencyWithValueTypeParameter.self, initializer: DependencyWithParameter3.init)
        
        let argumentDependency1 = DependencyWithValueTypeParameter(
            subDependency: StructureDependency(property1: "first")
        )
        let argumentDependency2 = DependencyWithValueTypeParameter(
            subDependency: StructureDependency(property1: "second")
        )

        let resolvedDependency1: DependencyWithParameter = container.resolve()
        let resolvedDependency2: DependencyWithParameter = container.resolve()
        let resolvedDependency3 = container.resolve(type: DependencyWithParameter3.self, argument: argumentDependency1)
        let resolvedDependency4 = container.resolve(type: DependencyWithParameter3.self, argument: argumentDependency2)

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Resolved different instances")
        XCTAssertTrue(resolvedDependency1.subDependency === resolvedDependency2.subDependency, "Resolved different instances")
        
        XCTAssertFalse(resolvedDependency1.subDependency === resolvedDependency3.subDependency1, "Resolved the same instance for a subdependency")
        XCTAssertFalse(resolvedDependency3.subDependency1 === resolvedDependency4.subDependency1, "Resolved the same instance for a subdependency")

        XCTAssertFalse(resolvedDependency3 === resolvedDependency4, "Resolved same instances")
        
        XCTAssertNotEqual(
            resolvedDependency3.subDependency2.subDependency.property1,
            resolvedDependency4.subDependency2.subDependency.property1,
            "Resolved instances with the same argument"
        )
    }
    
    func testCombiningSharedAndNonsharedDependenciesWithExplicitFactories() {
        container.register(in: .new) { _ in
            SimpleDependency()
        }
        container.register(in: .shared) { resolver in
            DependencyWithParameter(
                subDependency: resolver.resolve()
            )
        }
        container.register { resolver, argument in
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

        let resolvedDependency1: DependencyWithParameter = container.resolve()
        let resolvedDependency2: DependencyWithParameter = container.resolve()
        let resolvedDependency3 = container.resolve(type: DependencyWithParameter3.self, argument: argumentDependency1)
        let resolvedDependency4 = container.resolve(type: DependencyWithParameter3.self, argument: argumentDependency2)

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Resolved different instances")
        XCTAssertTrue(resolvedDependency1.subDependency === resolvedDependency2.subDependency, "Resolved different instances")
        
        XCTAssertFalse(resolvedDependency1.subDependency === resolvedDependency3.subDependency1, "Resolved the same instance for a subdependency")
        XCTAssertFalse(resolvedDependency3.subDependency1 === resolvedDependency4.subDependency1, "Resolved the same instance for a subdependency")

        XCTAssertFalse(resolvedDependency3 === resolvedDependency4, "Resolved same instances")
        
        XCTAssertNotEqual(
            resolvedDependency3.subDependency2.subDependency.property1,
            resolvedDependency4.subDependency2.subDependency.property1,
            "Resolved instances with the same argument"
        )
    }
}
