//
//  ContainerBaseTests.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import XCTest
import DependencyInjection

final class ContainerBaseTests: XCTestCase {
    class Dependency {}
    
    func testAutoclosureDependency() {
        let container = Container()
        
        let dependency = Dependency()
        container.register(dependency: dependency)
        
        let resolvedDependency: Dependency = container.resolve()
        
        XCTAssertTrue(dependency === resolvedDependency, "Container returned different instance")
    }
    
    func testAutoclosureDependencyWithExplicitType() {
        let container = Container()
        
        let dependency = Dependency()
        container.register(type: Dependency.self, dependency: dependency)
        
        let resolvedDependency: Dependency = container.resolve()
        
        XCTAssertTrue(dependency === resolvedDependency, "Container returned different instance")
    }

    func testDependencyRegisteredInDefaultScope() {
        let container = Container()
        
        container.register() { _ -> Dependency in
            Dependency()
        }
        
        let resolvedDependency1: Dependency = container.resolve()
        let resolvedDependency2: Dependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Container returned different instance")
    }

    func testDependencyRegisteredInDefaultScopeWithExplicitType() {
        let container = Container()
        
        container.register(type: Dependency.self) { _ -> Dependency in
            Dependency()
        }
        
        let resolvedDependency1: Dependency = container.resolve()
        let resolvedDependency2: Dependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Container returned different instance")
    }

    func testSharedDependency() {
        let container = Container()
        
        container.register(in: .shared) { _ -> Dependency in
            Dependency()
        }
        
        let resolvedDependency1: Dependency = container.resolve()
        let resolvedDependency2: Dependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Container returned different instance")
    }

    func testNonSharedDependency() {
        let container = Container()
        
        container.register(in: .new) { _ -> Dependency in
            Dependency()
        }
        
        let resolvedDependency1: Dependency = container.resolve()
        let resolvedDependency2: Dependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 !== resolvedDependency2, "Container returned the same instance")
    }

    func testNonSharedDependencyWithExplicitType() {
        let container = Container()
        
        container.register(type: Dependency.self, in: .new) { _ in
            Dependency()
        }
        
        let resolvedDependency1: Dependency = container.resolve()
        let resolvedDependency2: Dependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 !== resolvedDependency2, "Container returned the same instance")
    }
}
