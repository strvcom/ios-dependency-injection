//
//  ContainerBaseTests.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import XCTest
import DependencyInjection

final class ContainerBaseTests: XCTestCase {
    func testAutoclosureDependency() {
        let container = Container()
        
        let dependency = SimpleDependency()
        container.register(dependency: dependency)
        
        let resolvedDependency: SimpleDependency = container.resolve()
        
        XCTAssertTrue(dependency === resolvedDependency, "Container returned different instance")
    }
    
    func testAutoclosureDependencyWithExplicitType() {
        let container = Container()
        
        let dependency = SimpleDependency()
        container.register(type: SimpleDependency.self, dependency: dependency)
        
        let resolvedDependency: SimpleDependency = container.resolve()
        
        XCTAssertTrue(dependency === resolvedDependency, "Container returned different instance")
    }

    func testDependencyRegisteredInDefaultScope() {
        let container = Container()
        
        container.register() { _ -> SimpleDependency in
            SimpleDependency()
        }
        
        let resolvedDependency1: SimpleDependency = container.resolve()
        let resolvedDependency2: SimpleDependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Container returned different instance")
    }

    func testDependencyRegisteredInDefaultScopeWithExplicitType() {
        let container = Container()
        
        container.register(type: SimpleDependency.self) { _ -> SimpleDependency in
            SimpleDependency()
        }
        
        let resolvedDependency1: SimpleDependency = container.resolve()
        let resolvedDependency2: SimpleDependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Container returned different instance")
    }

    func testSharedDependency() {
        let container = Container()
        
        container.register(in: .shared) { _ -> SimpleDependency in
            SimpleDependency()
        }
        
        let resolvedDependency1: SimpleDependency = container.resolve()
        let resolvedDependency2: SimpleDependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Container returned different instance")
    }

    func testNonSharedDependency() {
        let container = Container()
        
        container.register(in: .new) { _ -> SimpleDependency in
            SimpleDependency()
        }
        
        let resolvedDependency1: SimpleDependency = container.resolve()
        let resolvedDependency2: SimpleDependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 !== resolvedDependency2, "Container returned the same instance")
    }

    func testNonSharedDependencyWithExplicitType() {
        let container = Container()
        
        container.register(type: SimpleDependency.self, in: .new) { _ in
            SimpleDependency()
        }
        
        let resolvedDependency1: SimpleDependency = container.resolve()
        let resolvedDependency2: SimpleDependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 !== resolvedDependency2, "Container returned the same instance")
    }
}
