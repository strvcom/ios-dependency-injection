//
//  DependencyRegistering.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

public protocol DependencyRegistering {
    typealias Resolver<Dependency> = (DependencyResolving) -> Dependency
    
    /// Register a dependency
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the `factory` closure is called on each `resolve` call. If `.shared` is used, the `factory` closure is called only the first time, the instance is cached and it is returned for all upcoming `resolve` calls i.e. it is a singleton
    ///   - factory: Closure that is called once the dependency is being resolved
    func register<Dependency>(type: Dependency.Type, in scope: DependencyScope, factory: @escaping Resolver<Dependency>)
}

// MARK: Overloaded factory methods
public extension DependencyRegistering {
    static var defaultScope: DependencyScope {
        DependencyScope.shared
    }
    
    func register<Dependency>(type: Dependency.Type, factory: @escaping Resolver<Dependency>) {
        register(type: type, in: Self.defaultScope, factory: factory)
    }
    
    func register<Dependency>(in scope: DependencyScope, factory: @escaping Resolver<Dependency>) {
        register(type: Dependency.self, in: scope, factory: factory)
    }

    func register<Dependency>(factory: @escaping Resolver<Dependency>) {
        register(type: Dependency.self, in: Self.defaultScope, factory: factory)
    }
}

// MARK: Overloaded autoclosure methods
public extension DependencyRegistering {
    func register<Dependency>(type: Dependency.Type, in scope: DependencyScope, dependency: @autoclosure @escaping () -> Dependency) {
        register(type: type, in: scope) { _ -> Dependency in
            dependency()
        }
    }
    
    func register<Dependency>(type: Dependency.Type, dependency: @autoclosure @escaping () -> Dependency) {
        register(type: type, in: Self.defaultScope) { _ -> Dependency in
            dependency()
        }
    }
    
    func register<Dependency>(in scope: DependencyScope, dependency: @autoclosure @escaping () -> Dependency) {
        register(type: Dependency.self, in: scope) { _ -> Dependency in
            dependency()
        }
    }
    
    func register<Dependency>(dependency: @autoclosure @escaping () -> Dependency) {
        register(type: Dependency.self, in: Self.defaultScope) { _ -> Dependency in
            dependency()
        }
    }
}
