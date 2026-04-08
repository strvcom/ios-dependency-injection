//
//  AsyncDependencyRegistering.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 17.12.2024.
//

import Foundation

/// A type that is able to register a dependency
public protocol AsyncDependencyRegistering {
    /// Factory closure that instantiates the required dependency without arguments
    typealias Factory<Dependency: Sendable> = @Sendable (any AsyncDependencyResolving) async -> Dependency

    /// Factory closure that instantiates the required dependency with variable arguments (1-3 supported)
    typealias FactoryWithArguments<Dependency: Sendable, each Argument: Sendable> = @Sendable (any AsyncDependencyResolving, repeat each Argument) async -> Dependency

    /// Register a dependency
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the `factory` closure is called on each `resolve` call. If `.shared` is used, the `factory` closure is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable>(type: Dependency.Type, in scope: DependencyScope, factory: @escaping Factory<Dependency>) async

    /// Register a dependency with variable arguments
    ///
    /// Uses Swift parameter packs to support 1-3 arguments with a single method signature.
    /// The arguments are typically parameters in an initializer of the dependency that are not registered in the same resolver (i.e. container),
    /// therefore, they need to be passed in `resolve` call. This registration method doesn't have any scope parameter for a reason - the container
    /// should always return a new instance for dependencies with arguments.
    /// Argument matching is based on compile-time types, so `ConcreteType` and `any Protocol` are different registrations.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable, each Argument: Sendable>(type: Dependency.Type, factory: @escaping FactoryWithArguments<Dependency, repeat each Argument>) async
}

// MARK: Overloaded factory methods
public extension AsyncDependencyRegistering {
    /// Register a dependency with an implicit type determined by the factory closure return type
    ///
    /// - Parameters:
    ///   - scope: Scope of the dependency. If `.new` is used, the `factory` closure is called on each `resolve` call. If `.shared` is used, the `factory` closure is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable>(in scope: DependencyScope, factory: @escaping Factory<Dependency>) async {
        await register(type: Dependency.self, in: scope, factory: factory)
    }

    /// Register a dependency with variable arguments. The type of the dependency is determined implicitly based on the factory closure return type
    ///
    /// Uses Swift parameter packs to support 1-3 arguments with a single method signature.
    /// The arguments are typically parameters in an initializer of the dependency that are not registered in the same resolver (i.e. container),
    /// therefore, they need to be passed in `resolve` call. This registration method doesn't have any scope parameter for a reason - the container
    /// should always return a new instance for dependencies with arguments.
    /// Argument matching is based on compile-time types, so `ConcreteType` and `any Protocol` are different registrations.
    ///
    /// - Parameters:
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable, each Argument: Sendable>(factory: @escaping FactoryWithArguments<Dependency, repeat each Argument>) async {
        await register(type: Dependency.self, factory: factory)
    }
}
