//
//  DependencyRegistering.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

public protocol DependencyRegistering {
    typealias Resolver<T> = (DependencyResolving) -> T
    
    /// Register a dependency
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the `factory` closure is called on each `resolve` call. If `.shared` is used, the `factory` closure is called only the first time, the instance is cached and it is returned for all upcoming `resolve` calls i.e. it is a singleton
    ///   - factory: Closure that is called once the dependency is being resolved
    func register<T>(type: T.Type, in scope: DependencyScope, factory: @escaping Resolver<T>)
}

// MARK: Overloaded factory methods
public extension DependencyRegistering {
    static var defaultScope: DependencyScope {
        DependencyScope.shared
    }
    
    func register<T>(type: T.Type, factory: @escaping Resolver<T>) {
        register(type: type, in: Self.defaultScope, factory: factory)
    }
    
    func register<T>(in scope: DependencyScope, factory: @escaping Resolver<T>) {
        register(type: T.self, in: scope, factory: factory)
    }

    func register<T>(factory: @escaping Resolver<T>) {
        register(type: T.self, in: Self.defaultScope, factory: factory)
    }
}

// MARK: Overloaded autoregistration methods
public extension DependencyRegistering {
    func register<T>(type: T.Type, in scope: DependencyScope, dependency: @autoclosure @escaping () -> T) {
        register(type: type, in: scope) { _ -> T in
            dependency()
        }
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
