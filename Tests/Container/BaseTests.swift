//
//  BaseTests.swift
//  
//
//  Created by Jan Schwarz on 25.03.2021.
//

import XCTest
@testable import DependencyInjectionModule

final class BaseTests: DITestCase {
    func testAutoclosureDependency() {
        let dependency = SimpleDependency()
        container.register(dependency: dependency)
        
        let resolvedDependency: SimpleDependency = container.resolve()
        
        XCTAssertTrue(dependency === resolvedDependency, "Container returned different instance")
    }
    
    func testAutoclosureDependencyWithExplicitType() {
        let dependency = SimpleDependency()
        container.register(type: SimpleDependency.self, dependency: dependency)
        
        let resolvedDependency: SimpleDependency = container.resolve()
        
        XCTAssertTrue(dependency === resolvedDependency, "Container returned different instance")
    }

    func testDependencyRegisteredInDefaultScope() {
        container.register { _ -> SimpleDependency in
            SimpleDependency()
        }
        
        let resolvedDependency1: SimpleDependency = container.resolve()
        let resolvedDependency2: SimpleDependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Container returned different instance")
    }

    func testDependencyRegisteredInDefaultScopeWithExplicitType() {
        container.register(type: SimpleDependency.self) { _ -> SimpleDependency in
            SimpleDependency()
        }
        
        let resolvedDependency1: SimpleDependency = container.resolve()
        let resolvedDependency2: SimpleDependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Container returned different instance")
    }

    func testSharedDependency() {
        container.register(in: .shared) { _ -> SimpleDependency in
            SimpleDependency()
        }
        
        let resolvedDependency1: SimpleDependency = container.resolve()
        let resolvedDependency2: SimpleDependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 === resolvedDependency2, "Container returned different instance")
    }

    func testNonSharedDependency() {
        container.register(in: .new) { _ -> SimpleDependency in
            SimpleDependency()
        }
        
        let resolvedDependency1: SimpleDependency = container.resolve()
        let resolvedDependency2: SimpleDependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 !== resolvedDependency2, "Container returned the same instance")
    }

    func testNonSharedDependencyWithExplicitType() {
        container.register(type: SimpleDependency.self, in: .new) { _ in
            SimpleDependency()
        }
        
        let resolvedDependency1: SimpleDependency = container.resolve()
        let resolvedDependency2: SimpleDependency = container.resolve()

        XCTAssertTrue(resolvedDependency1 !== resolvedDependency2, "Container returned the same instance")
    }
    
    func testUnregisteredDependency() {
        XCTAssertThrowsError(
            try container.tryResolve(type: SimpleDependency.self),
            "Resolver didn't throw an error") { error in
                guard let resolutionError = error as? ResolutionError else {
                    XCTFail("Incorrect error type")
                    return
                }
                
                switch resolutionError {
                case .dependencyNotRegistered:
                    XCTAssertNotEqual(resolutionError.localizedDescription, "", "Error description is empty")
                default:
                    XCTFail("Incorrect resolution error")
                }
            }
    }
}
