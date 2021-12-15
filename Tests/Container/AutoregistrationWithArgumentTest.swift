//
//  AutoregistrationWithArgumentTest.swift
//  
//
//  Created by Jan on 05.08.2021.
//

import XCTest
import DependencyInjection

final class AutoregistrationWithArgumentTest: XCTestCase {
    func testRegistration() {
        let container = Container()

        let subDependency = SimpleDependency()
        container.register(dependency: subDependency)
        container.autoregister(argument: DependencyWithValueTypeParameter.self, initializer: DependencyWithParameter2.init)

        let argument = DependencyWithValueTypeParameter()
        let firstResolved: DependencyWithParameter2 = container.resolve(argument: argument)
        
        XCTAssertTrue(argument === firstResolved.subDependency2, "Container returned dependency with different argument")
        
        XCTAssertTrue(subDependency === firstResolved.subDependency1, "Different instances of subdependencies")
    }
}
