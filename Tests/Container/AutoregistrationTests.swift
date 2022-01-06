//
//  AutoregistrationTests.swift
//  
//
//  Created by Jan on 05.08.2021.
//

import XCTest
import DependencyInjection

final class AutoregistrationTests: XCTestCase {
    class Dependency {
        let subdependency: Subdependency
        
        init(subdependency: Subdependency) {
            self.subdependency = subdependency
        }
    }
    
    class Subdependency {}
    
    func testSharedAutoRegistration() {
        let container = Container()
        
        let subdependency = Subdependency()
        container.register(dependency: subdependency)
        container.autoregister(initializer: Dependency.init)
        
        let firstResolved: Dependency = container.resolve()
        let secondResolved: Dependency = container.resolve()

        XCTAssertTrue(firstResolved === secondResolved, "Container returned different instances")
    }
}
