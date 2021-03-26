//
//  ContainerIdentifierTests.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import XCTest
import DependencyInjection

final class ContainerIdentifierTests: XCTestCase {
    class Dependency {}
    
    func testSimpleRegistration() {
        let container = Container()
        let identifier = UUID().uuidString

        let dependency = Dependency()
        container.register(with: identifier, dependency: dependency)
        
        let resolvedDependency: Dependency = container.resolve(with: identifier)
        
        XCTAssertTrue(dependency === resolvedDependency, "Container returned different instance")
    }
    
    func testUnsuccessfulResolution() {
        let container = Container()
        let identifier = UUID().uuidString

        let dependency = Dependency()
        container.register(with: identifier, dependency: dependency)

        XCTAssertThrowsError(try container.tryResolve(type: Dependency.self, with: nil))
    }
}
