//
//  PropertyWrapperTests.swift
//  
//
//  Created by Jan Schwarz on 28.03.2021.
//

import XCTest
import DependencyInjectionModule

final class PropertyWrapperTests: DITestCase {
    override func tearDown() {        
        Container.shared.clean()

        super.tearDown()
    }
    
    func testInjectionWithSharedContainer() {
        struct Module {
            @Injected var resolvedDependency: SimpleDependency
        }

        let dependency = SimpleDependency()
        Container.shared.register(dependency: dependency)
        
        let module = Module()
        
        XCTAssertTrue(dependency === module.resolvedDependency, "Container returned different instance")
    }
    
    func testInjectionWithCustomContainer() {
        struct Module {
            static var container: Container!
            
            @Injected(from: container) var resolvedDependency: SimpleDependency
        }

        let dependency = SimpleDependency()
        container.register(dependency: dependency)
        
        Module.container = container
        let module = Module()
        
        XCTAssertTrue(dependency === module.resolvedDependency, "Container returned different instance")
    }
    
    func testLazyInjectionWithSharedContainer() {
        struct Module {
            @LazyInjected var resolvedDependency: SimpleDependency
        }
        
        // 1: Create a module instance
        let module = Module()

        // 2: Only after that register the dependency
        let dependency = SimpleDependency()
        Container.shared.register(dependency: dependency)
        
        // 3: Get resolved dependency
        XCTAssertTrue(dependency === module.resolvedDependency, "Container returned different instance")
    }
    
    func testLazyInjectionWithCustomContainer() {
        struct Module {
            static var container: Container!
            
            @LazyInjected(from: container) var resolvedDependency: SimpleDependency
        }

        Module.container = container

        // 1: Create a module instance
        let module = Module()

        // 2: Only after that register the dependency
        let dependency = SimpleDependency()
        container.register(dependency: dependency)
        
        // 3: Get resolved dependency
        XCTAssertTrue(dependency === module.resolvedDependency, "Container returned different instance")
    }
}
