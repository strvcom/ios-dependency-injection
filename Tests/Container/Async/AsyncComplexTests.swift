//
//  AsyncComplexTests.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 19.12.2024.
//

import XCTest
import DependencyInjection

final class AsyncComplexTests: AsyncDITestCase {
    func testCleanContainer() async {
        await container.register { _ in
            SimpleDependency()
        }
        
        let resolvedDependency = try? await container.tryResolve(type: SimpleDependency.self)
        
        XCTAssertNotNil(resolvedDependency, "Couldn't resolve dependency")
        
        await container.clean()
        
        let unresolvedDependency = try? await container.tryResolve(type: SimpleDependency.self)
        
        XCTAssertNil(unresolvedDependency, "Dependency wasn't cleaned")
    }
    
    func testReleaseSharedInstances() async {
        await container.register(in: .shared) { _ in
            SimpleDependency()
        }
        
        var resolvedDependency1: SimpleDependency? = await container.resolve(type: SimpleDependency.self)
        weak var resolvedDependency2 = await container.resolve(type: SimpleDependency.self)

        XCTAssertNotNil(resolvedDependency1, "Shared instance wasn't resolved")
        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Different instancies of a shared dependency")

        await container.releaseSharedInstances()
        
        let resolvedDependency3 = await container.resolve(type: SimpleDependency.self)

        XCTAssertFalse(resolvedDependency1 === resolvedDependency3, "Shared instance wasn't released")
        
        resolvedDependency1 = nil
        
        XCTAssertNil(resolvedDependency2, "Shared instance wasn't released")
    }
    
    func testReregistration() async {
        await container.register(type: DIProtocol.self, in: .shared) { _ in
            SimpleDependency()
        }
        
        let resolvedSimpleDependency = await container.resolve(type: DIProtocol.self)
        
        XCTAssertTrue(resolvedSimpleDependency is SimpleDependency, "Resolved dependency of wrong type")
        
        await container.register(type: DIProtocol.self, in: .shared) { _ in
            StructureDependency.default
        }
        
        let resolvedStructureDependency = await container.resolve(type: DIProtocol.self)

        XCTAssertTrue(resolvedStructureDependency is StructureDependency, "Resolved dependency of wrong type")
    }
    
    func testSameDependencyTypeRegisteredWithDifferentTypes() async {
        await container.register(type: DIProtocol.self, in: .shared) { _ in
            StructureDependency(property1: "first")
        }
        
        await container.register(type: StructureDependency.self, in: .shared) { _ in
            StructureDependency(property1: "second")
        }
        
        let resolvedProtocolDependency: DIProtocol = await container.resolve()
        let resolvedTypeDependency: StructureDependency = await container.resolve()
        
        XCTAssertTrue(resolvedProtocolDependency is StructureDependency, "Resolved dependency of wrong type")
        XCTAssertEqual(resolvedTypeDependency.property1, "second", "Resolved dependency from a wrong factory")

        XCTAssertNotEqual(
            (resolvedProtocolDependency as? StructureDependency)?.property1,
            resolvedTypeDependency.property1,
            "Resolved same instances"
        )
    }
    
    func testCombiningSharedAndNonsharedDependencies() async {
        await container.register(in: .new) { _ in
            SimpleDependency()
        }
        await container.register(in: .shared) {
            DependencyWithParameter(subDependency: await $0.resolve())
        }
        await container.register {
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

        let resolvedDependency1: DependencyWithParameter = await container.resolve()
        let resolvedDependency2: DependencyWithParameter = await container.resolve()
        let resolvedDependency3 = await container.resolve(type: DependencyWithParameter3.self, argument: argumentDependency1)
        let resolvedDependency4 = await container.resolve(type: DependencyWithParameter3.self, argument: argumentDependency2)

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
    
    func testCombiningSharedAndNonsharedDependenciesWithExplicitFactories() async {
        await container.register(in: .new) { _ in
            SimpleDependency()
        }
        await container.register(in: .shared) {
            DependencyWithParameter(
                subDependency: await $0.resolve()
            )
        }
        await container.register { resolver, argument in
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

        let resolvedDependency1: DependencyWithParameter = await container.resolve()
        let resolvedDependency2: DependencyWithParameter = await container.resolve()
        let resolvedDependency3 = await container.resolve(type: DependencyWithParameter3.self, argument: argumentDependency1)
        let resolvedDependency4 = await container.resolve(type: DependencyWithParameter3.self, argument: argumentDependency2)

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
