//
//  DependencyRegistering.swift
//
//
//  Created by Jan Schwarz on 25.03.2021.
//

import Foundation

/// A type that is able to register a dependency
public protocol DependencyRegistering {
    /// Factory closure that instantiates the required dependency without arguments
    typealias Factory<Dependency> = (DependencyResolving) -> Dependency

    /// Factory closure that instantiates the required dependency with variable arguments (1-3 supported)
    typealias FactoryWithArguments<Dependency, each Argument> = (DependencyResolving, repeat each Argument) -> Dependency

    /// Register a dependency
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the `factory` closure is called on each `resolve` call. If `.shared` is used, the `factory` closure is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency>(type: Dependency.Type, in scope: DependencyScope, factory: @escaping Factory<Dependency>)

    /// Register a dependency with variable arguments
    ///
    /// Uses Swift parameter packs to support 1-3 arguments with a single method signature.
    /// The arguments are typically parameters in an initializer of the dependency that are not registered in the same resolver (i.e. container),
    /// therefore, they need to be passed in `resolve` call. This registration method doesn't have any scope parameter for a reason - the container
    /// should always return a new instance for dependencies with arguments.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency, each Argument>(type: Dependency.Type, factory: @escaping FactoryWithArguments<Dependency, repeat each Argument>)
}

// MARK: Overloaded factory methods
public extension DependencyRegistering {
    /// Register a dependency with type and a single-parameter factory (resolver only).
    ///
    /// This overload ensures that `register(type: X.self) { _ in ... }` creates a zero-argument registration,
    /// so that `resolve()` without arguments succeeds. Without it, the compiler may bind to the parameter-pack
    /// overload and infer a one-argument registration, causing `unmatchingArgumentType` when resolving with no arguments.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - factory: Closure that is called when the dependency is being resolved (receives the resolver only)
    func register<Dependency>(type: Dependency.Type, factory: @escaping Factory<Dependency>) {
        register(type: type, in: .new, factory: factory)
    }

    /// Register a dependency with an implicit type determined by the factory closure return type
    ///
    /// - Parameters:
    ///   - scope: Scope of the dependency. If `.new` is used, the `factory` closure is called on each `resolve` call. If `.shared` is used, the `factory` closure is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency>(in scope: DependencyScope, factory: @escaping Factory<Dependency>) {
        register(type: Dependency.self, in: scope, factory: factory)
    }

    /// Register a dependency with variable arguments. The type of the dependency is determined implicitly based on the factory closure return type
    ///
    /// Uses Swift parameter packs to support 1-3 arguments with a single method signature.
    /// The arguments are typically parameters in an initializer of the dependency that are not registered in the same resolver (i.e. container),
    /// therefore, they need to be passed in `resolve` call. This registration method doesn't have any scope parameter for a reason - the container
    /// should always return a new instance for dependencies with arguments.
    ///
    /// - Parameters:
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency, each Argument>(factory: @escaping FactoryWithArguments<Dependency, repeat each Argument>) {
        register(type: Dependency.self, factory: factory)
    }
}

// MARK: Overloaded autoclosure methods
public extension DependencyRegistering {
    /// Register a dependency
    ///
    /// DISCUSSION: Registration methods with autoclosures don't have any scope parameter for a reason.
    /// The container always returns the same instance of the dependency because the autoclosure simply wraps the instance passed as a parameter and returns it whenever it is called
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - dependency: Dependency that should be registered
    func register<Dependency>(type: Dependency.Type, dependency: @autoclosure @escaping () -> Dependency) {
        register(type: type, in: .shared) { _ -> Dependency in
            dependency()
        }
    }

    /// Register a dependency with an implicit type determined by the factory closure return type
    ///
    /// DISCUSSION: Registration methods with autoclosures don't have any scope parameter for a reason.
    /// The container always return the same instance of the dependency because the autoclosure simply wraps the instance passed as a parameter and returns it whenever it is called
    ///
    /// - Parameters:
    ///   - dependency: Dependency that should be registered
    func register<Dependency>(dependency: @autoclosure @escaping () -> Dependency) {
        register(type: Dependency.self, in: .shared) { _ -> Dependency in
            dependency()
        }
    }
}
