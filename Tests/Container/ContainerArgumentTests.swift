//
//  ContainerArgumentTests.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import XCTest
import DependencyInjection

final class ContainerArgumentTests: XCTestCase {
    func testRegistration() {
        let container = Container()

        container.register { (resolver, argument: StructureDependency) -> DependencyWithValueTypeParameter in
            DependencyWithValueTypeParameter(subDependency: argument)
        }
        
        let argument = StructureDependency(property1: "48")
        let resolvedDependency: DependencyWithValueTypeParameter = container.resolve(argument: argument)
        
        XCTAssertEqual(argument, resolvedDependency.subDependency, "Container returned dependency with different argument")
    }
    
    func testRegistrationWithExplicitType() {
        let container = Container()

        container.register(type: DependencyWithValueTypeParameter.self) { (resolver, argument: StructureDependency) in
            DependencyWithValueTypeParameter(subDependency: argument)
        }
        
        let argument = StructureDependency(property1: "48")
        let resolvedDependency: DependencyWithValueTypeParameter = container.resolve(argument: argument)
        
        XCTAssertEqual(argument, resolvedDependency.subDependency, "Container returned dependency with different argument")
    }
}
