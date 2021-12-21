//
//  ContainerArgumentTests.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import XCTest
@testable import DependencyInjectionModule

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
    
    func testUnmatchingArgumentType() {
        let container = Container()

        container.register { (resolver, argument: StructureDependency) -> DependencyWithValueTypeParameter in
            DependencyWithValueTypeParameter(subDependency: argument)
        }
        
        let argument = 48
        
        XCTAssertThrowsError(
            try container.tryResolve(type: DependencyWithValueTypeParameter.self, argument: argument),
            "Resolver didn't throw an error") { error in
                guard let resolutionError = error as? ResolutionError else {
                    XCTFail("Error of a wrong type")
                    return
                }
                
                switch resolutionError {
                case .unmatchingArgumentType:
                    XCTAssertNotEqual(resolutionError.localizedDescription, "", "Error description is empty")
                default:
                    XCTFail("Error of a wrong type")
                }
            }
    }
}
