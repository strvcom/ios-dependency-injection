//
//  AutoregistrationWithArgumentTest.swift
//  
//
//  Created by Jan on 05.08.2021.
//

import XCTest
@testable import DependencyInjectionModule

final class AutoregistrationWithArgumentTest: DITestCase {
    func testRegistrationWithoutParameter() {
        container.autoregister(argument: StructureDependency.self, initializer: DependencyWithValueTypeParameter.init)
        
        let argument = StructureDependency(property1: "48")
        let resolvedDependency: DependencyWithValueTypeParameter = container.resolve(argument: argument)
        
        XCTAssertEqual(argument, resolvedDependency.subDependency, "Container returned dependency with different argument")
    }
    
    func testRegistrationWithOneParameterFirstPermutation() {
        let subDependency = DependencyWithValueTypeParameter()
        container.register(dependency: subDependency)
        container.autoregister(argument: SimpleDependency.self, initializer: DependencyWithParameter2.init)

        let argument = SimpleDependency()
        
        let firstResolved: DependencyWithParameter2 = container.resolve(argument: argument)
        let secondResolved: DependencyWithParameter2 = container.resolve(argument: argument)

        XCTAssertTrue(argument === firstResolved.subDependency1, "Container returned dependency with different argument")
        XCTAssertTrue(argument === secondResolved.subDependency1, "Container returned dependency with different argument")

        XCTAssertTrue(firstResolved.subDependency2 === secondResolved.subDependency2, "Different instances of subdependencies")
    }
    
    func testRegistrationWithOneParameterSecondPermutation() {
        container.autoregister(initializer: SimpleDependency.init)
        container.autoregister(argument: DependencyWithValueTypeParameter.self, initializer: DependencyWithParameter2.init)

        let argument = DependencyWithValueTypeParameter()
        
        let firstResolved: DependencyWithParameter2 = container.resolve(argument: argument)
        let secondResolved: DependencyWithParameter2 = container.resolve(argument: argument)

        XCTAssertTrue(argument === firstResolved.subDependency2, "Container returned dependency with different argument")
        XCTAssertTrue(argument === secondResolved.subDependency2, "Container returned dependency with different argument")

        XCTAssertTrue(firstResolved.subDependency1 === secondResolved.subDependency1, "Different instances of subdependencies")
    }
    
    func testRegistrationWithTwoParameterFirstPermutation() {
        let subDependency = DependencyWithValueTypeParameter()
        container.register(dependency: subDependency)
        container.autoregister(initializer: SimpleDependency.init)
        container.autoregister(initializer: DependencyWithParameter.init)
        container.autoregister(argument: SimpleDependency.self, initializer: DependencyWithParameter3.init)

        let argument = SimpleDependency()
        
        let firstResolved: DependencyWithParameter3 = container.resolve(argument: argument)
        let secondResolved: DependencyWithParameter3 = container.resolve(argument: argument)

        XCTAssertTrue(argument === firstResolved.subDependency1, "Container returned dependency with different argument")
        XCTAssertTrue(argument === secondResolved.subDependency1, "Container returned dependency with different argument")

        XCTAssertTrue(firstResolved.subDependency2 === secondResolved.subDependency2, "Different instances of subdependencies")
        XCTAssertTrue(firstResolved.subDependency3 === secondResolved.subDependency3, "Different instances of subdependencies")
    }
    
    func testRegistrationWithTwoParameterSecondPermutation() {
        container.autoregister(initializer: SimpleDependency.init)
        container.autoregister(initializer: DependencyWithParameter.init)
        container.autoregister(argument: DependencyWithValueTypeParameter.self, initializer: DependencyWithParameter3.init)

        let argument = DependencyWithValueTypeParameter()

        let firstResolved: DependencyWithParameter3 = container.resolve(argument: argument)
        let secondResolved: DependencyWithParameter3 = container.resolve(argument: argument)

        XCTAssertTrue(argument === firstResolved.subDependency2, "Container returned dependency with different argument")
        XCTAssertTrue(argument === secondResolved.subDependency2, "Container returned dependency with different argument")

        XCTAssertTrue(firstResolved.subDependency1 === secondResolved.subDependency1, "Different instances of subdependencies")
        XCTAssertTrue(firstResolved.subDependency3 === secondResolved.subDependency3, "Different instances of subdependencies")
    }

    func testRegistrationWithTwoParameterThirdPermutation() {
        let subDependency = DependencyWithValueTypeParameter()
        container.register(dependency: subDependency)
        container.autoregister(initializer: SimpleDependency.init)
        container.autoregister(argument: DependencyWithParameter.self, initializer: DependencyWithParameter3.init)

        let argument = DependencyWithParameter(subDependency: SimpleDependency())
        
        let firstResolved: DependencyWithParameter3 = container.resolve(argument: argument)
        let secondResolved: DependencyWithParameter3 = container.resolve(argument: argument)

        XCTAssertTrue(argument === firstResolved.subDependency3, "Container returned dependency with different argument")
        XCTAssertTrue(argument === secondResolved.subDependency3, "Container returned dependency with different argument")

        XCTAssertTrue(firstResolved.subDependency2 === secondResolved.subDependency2, "Different instances of subdependencies")
        XCTAssertTrue(firstResolved.subDependency1 === secondResolved.subDependency1, "Different instances of subdependencies")
    }
}
