//
//  AsyncDependencyRegistering.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 17.12.2024.
//

import Foundation

/// A type that is able to register a dependency
public protocol AsyncDependencyRegistering {
    /// Factory closure that instantiates the required dependency
    typealias Factory<Dependency: Sendable> = @Sendable (any AsyncDependencyResolving) async -> Dependency

    /// Factory closure that instantiates the required dependency with the given variable argument
    typealias FactoryWithOneArgument<Dependency: Sendable, Argument: Sendable> = @Sendable (any AsyncDependencyResolving, Argument) async -> Dependency

    /// Factory closure that instantiates the required dependency with two variable arguments
    typealias FactoryWithTwoArguments<Dependency: Sendable, Argument1: Sendable, Argument2: Sendable> = @Sendable (any AsyncDependencyResolving, Argument1, Argument2) async -> Dependency
    
    /// Factory closure that instantiates the required dependency with three variable arguments
    typealias FactoryWithThreeArguments<Dependency: Sendable, Argument1: Sendable, Argument2: Sendable, Argument3: Sendable> = @Sendable (any AsyncDependencyResolving, Argument1, Argument2, Argument3) async -> Dependency
    
    /// Register a dependency
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - scope: Scope of the dependency. If `.new` is used, the `factory` closure is called on each `resolve` call. If `.shared` is used, the `factory` closure is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable>(type: Dependency.Type, in scope: DependencyScope, factory: @escaping Factory<Dependency>) async

    /// Register a dependency with a variable argument
    ///
    /// The argument is typically a parameter in an initiliazer of the dependency that is not registered in the same resolver (i.e. container),
    /// therefore, it needs to be passed in `resolve` call
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable, Argument: Sendable>(type: Dependency.Type, factory: @escaping FactoryWithOneArgument<Dependency, Argument>) async

    /// Register a dependency with two variable arguments
    ///
    /// The arguments are typically parameters in an initializer of the dependency that are not registered in the same resolver (i.e. container),
    /// therefore, they need to be passed in `resolve` call
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the arguments conform to ``Equatable`` to compare the arguments to tell whether a shared instance with given arguments was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable, Argument1: Sendable, Argument2: Sendable>(type: Dependency.Type, factory: @escaping FactoryWithTwoArguments<Dependency, Argument1, Argument2>) async

    /// Register a dependency with three variable arguments
    ///
    /// The arguments are typically parameters in an initializer of the dependency that are not registered in the same resolver (i.e. container),
    /// therefore, they need to be passed in `resolve` call
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the arguments conform to ``Equatable`` to compare the arguments to tell whether a shared instance with given arguments was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable, Argument1: Sendable, Argument2: Sendable, Argument3: Sendable>(type: Dependency.Type, factory: @escaping FactoryWithThreeArguments<Dependency, Argument1, Argument2, Argument3>) async
}

// MARK: Overloaded factory methods
public extension AsyncDependencyRegistering {
    /// Default ``DependencyScope`` value
    ///
    /// The default value is `shared`
    static var defaultScope: DependencyScope {
        DependencyScope.shared
    }

    /// Register a dependency in the default ``DependencyScope``, i.e. in the `shared` scope
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable>(type: Dependency.Type, factory: @escaping Factory<Dependency>) async {
        await register(type: type, in: Self.defaultScope, factory: factory)
    }

    /// Register a dependency with an implicit type determined by the factory closure return type
    ///
    /// - Parameters:
    ///   - scope: Scope of the dependency. If `.new` is used, the `factory` closure is called on each `resolve` call. If `.shared` is used, the `factory` closure is called only the first time, the instance is cached and it is returned for all subsequent `resolve` calls, i.e. it is a singleton
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable>(in scope: DependencyScope, factory: @escaping Factory<Dependency>) async {
        await register(type: Dependency.self, in: scope, factory: factory)
    }

    /// Register a dependency with an implicit type determined by the factory closure return type and in the default ``DependencyScope``, i.e. in the `shared` scope
    ///
    /// - Parameters:
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable>(factory: @escaping Factory<Dependency>) async {
        await register(type: Dependency.self, in: Self.defaultScope, factory: factory)
    }

    /// Register a dependency with a variable argument. The type of the dependency is determined implicitly based on the factory closure return type
    ///
    /// The argument is typically a parameter in an initializer of the dependency that is not registered in the same resolver (i.e. container),
    /// therefore, it needs to be passed in `resolve` call
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to ``Equatable`` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable, Argument: Sendable>(factory: @escaping FactoryWithOneArgument<Dependency, Argument>) async {
        await register(type: Dependency.self, factory: factory)
    }

    /// Register a dependency with two variable arguments. The type of the dependency is determined implicitly based on the factory closure return type
    ///
    /// The arguments are typically parameters in an initializer of the dependency that are not registered in the same resolver (i.e. container),
    /// therefore, they need to be passed in `resolve` call
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the arguments conform to ``Equatable`` to compare the arguments to tell whether a shared instance with given arguments was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable, Argument1: Sendable, Argument2: Sendable>(factory: @escaping FactoryWithTwoArguments<Dependency, Argument1, Argument2>) async {
        await register(type: Dependency.self, factory: factory)
    }

    /// Register a dependency with three variable arguments. The type of the dependency is determined implicitly based on the factory closure return type
    ///
    /// The arguments are typically parameters in an initializer of the dependency that are not registered in the same resolver (i.e. container),
    /// therefore, they need to be passed in `resolve` call
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The container should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the arguments conform to ``Equatable`` to compare the arguments to tell whether a shared instance with given arguments was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the container.
    ///
    /// - Parameters:
    ///   - factory: Closure that is called when the dependency is being resolved
    func register<Dependency: Sendable, Argument1: Sendable, Argument2: Sendable, Argument3: Sendable>(factory: @escaping FactoryWithThreeArguments<Dependency, Argument1, Argument2, Argument3>) async {
        await register(type: Dependency.self, factory: factory)
    }
}
