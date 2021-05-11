//
//  PropertyWrapperTests.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import XCTest
import DependencyInjection

final class PropertyWrapperTests: XCTestCase {
    class Dependency {}
    
    override func tearDown() {
        super.tearDown()
        
        Container.shared.clean()
    }
    
    func testInjection() {
        struct Module {
            @Injected var resolvedDependency: Dependency
        }

        let dependency = Dependency()
        Container.shared.register(dependency: dependency)
        
        let module = Module()
        
        XCTAssertTrue(dependency === module.resolvedDependency, "Container returned different instance")
    }
    
    func testInjectionCustomContainer() {
        struct Module {
            static var container: Container!
            
            @Injected(from: container) var resolvedDependency: Dependency
        }

        let container = Container()
        
        let dependency = Dependency()
        container.register(dependency: dependency)
        
        Module.container = container
        let module = Module()
        
        XCTAssertTrue(dependency === module.resolvedDependency, "Container returned different instance")
    }
    
    func testLazyInjection() {
        struct Module {
            @LazyInjected var resolvedDependency: Dependency
        }
        
        // 1: Create a module instance
        let module = Module()

        // 2: Only after that register the dependency
        let dependency = Dependency()
        Container.shared.register(dependency: dependency)
        
        // 3: Get resolved dependency
        XCTAssertTrue(dependency === module.resolvedDependency, "Container returned different instance")
    }
}
