//
//  File.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

public protocol DependencyRegistering {
    func register<T>(type: T.Type, in scope: DependencyScope, factory: @escaping (DependencyResolving) -> T)
}

public extension DependencyRegistering {
    static var defaultScope: DependencyScope {
        DependencyScope.shared
    }
    
    func register<T>(type: T.Type, factory: @escaping (DependencyResolving) -> T) {
        register(type: type, in: Self.defaultScope, factory: factory)
    }
    
    func register<T>(in scope: DependencyScope, factory: @escaping (DependencyResolving) -> T) {
        register(type: T.self, in: scope, factory: factory)
    }
    
    func register<T>(factory: @escaping (DependencyResolving) -> T) {
        register(type: T.self, in: Self.defaultScope, factory: factory)
    }

    func register<T>(type: T.Type, dependency: @autoclosure @escaping () -> T) {
        register(type: type, in: Self.defaultScope) { _ -> T in
            dependency()
        }
    }
    
    func register<T>(in scope: DependencyScope, dependency: @autoclosure @escaping () -> T) {
        register(type: T.self, in: scope) { _ -> T in
            dependency()
        }
    }
    
    func register<T>(dependency: @autoclosure @escaping () -> T) {
        register(type: T.self, in: Self.defaultScope) { _ -> T in
            dependency()
        }
    }
}
