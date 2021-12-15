//
//  AutoregistrationTests.swift
//  
//
//  Created by Jan on 05.08.2021.
//

import XCTest
import DependencyInjection

final class AutoregistrationTests: XCTestCase {
    func testSharedAutoRegistration() {
        let container = Container()
        
        let subdependency = SimpleDependency()
        container.register(dependency: subdependency)
        container.autoregister(initializer: DependencyWithParameter.init)
        
        let firstResolved: DependencyWithParameter = container.resolve()
        let secondResolved: DependencyWithParameter = container.resolve()

        XCTAssertTrue(firstResolved === secondResolved, "Container returned different instances")
    }
}
