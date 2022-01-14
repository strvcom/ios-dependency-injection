//
//  DependencyRegistering.swift
//  
//
//  Created by Jan Schwarz on 25.03.2021.
//

import Foundation

/// A type that is able to register a dependency
public protocol DependencyRegistering {
    /// Factory closure that resolves the required dependency
    typealias Resolver<Dependency> = (DependencyResolving) -> Dependency
    
    /// Register a dependency
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the `factory` closure is called on each `resolve` call. If `.shared` is used, the `factory` closure is called only the first time, the instance is cached and it is returned for all upcoming `resolve` calls i.e. it is a singleton
    ///   - factory: Closure that is called once the dependency is being resolved
    func register<Dependency>(type: Dependency.Type, in scope: DependencyScope, factory: @escaping Resolver<Dependency>)
}

// MARK: Overloaded factory methods
public extension DependencyRegistering {
    /// Default `DependencyScope` value
    ///
    /// The default value is `shared`
    static var defaultScope: DependencyScope {
        DependencyScope.shared
    }
    
    /// Register a dependency in the default ``DependencyScope``, i.e. in the `shared` scope
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - factory: Closure that is called once the dependency is being resolved
    func register<Dependency>(type: Dependency.Type, factory: @escaping Resolver<Dependency>) {
        register(type: type, in: Self.defaultScope, factory: factory)
    }
    
    /// Register a dependency with an implicite type determined by the factory closure return type
    ///
    /// - Parameters:
    ///   - scope: Scope of the dependency. If `.new` is used, the `factory` closure is called on each `resolve` call. If `.shared` is used, the `factory` closure is called only the first time, the instance is cached and it is returned for all upcoming `resolve` calls i.e. it is a singleton
    ///   - factory: Closure that is called once the dependency is being resolved
    func register<Dependency>(in scope: DependencyScope, factory: @escaping Resolver<Dependency>) {
        register(type: Dependency.self, in: scope, factory: factory)
    }

    /// Register a dependency with an implicite type determined by the factory closure return type and in the default ``DependencyScope``, i.e. in the `shared` scope
    ///
    /// - Parameters:
    ///   - factory: Closure that is called once the dependency is being resolved
    func register<Dependency>(factory: @escaping Resolver<Dependency>) {
        register(type: Dependency.self, in: Self.defaultScope, factory: factory)
    }
}

// MARK: Overloaded autoclosure methods
public extension DependencyRegistering {
    /// Register a dependency
    ///
    /// DISCUSSION: Registration methods with autoclosures don't have any scope parameter for a reason.
    /// The resolver always returns the same instance of the dependency because the autoclosure simply wraps the instance passed as a parameter and returns it whenever it is called
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - dependency: Dependency that should be registered
    func register<Dependency>(type: Dependency.Type, dependency: @autoclosure @escaping () -> Dependency) {
        register(type: type, in: .shared) { _ -> Dependency in
            dependency()
        }
    }
    
    /// Register a dependency with an implicite type determined by the factory closure return type
    ///
    /// DISCUSSION: Registration methods with autoclosures don't have any scope parameter for a reason.
    /// The resolver always return the same instance of the dependency because the autoclosure simply wraps the instance passed as a parameter and returns it whenever it is called
    ///
    /// - Parameters:
    ///   - dependency: Dependency that should be registered
    func register<Dependency>(dependency: @autoclosure @escaping () -> Dependency) {
        register(type: Dependency.self, in: .shared) { _ -> Dependency in
            dependency()
        }
    }
}
