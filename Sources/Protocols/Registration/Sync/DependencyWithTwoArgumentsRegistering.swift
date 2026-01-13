//
//  DependencyWithTwoArgumentsRegistering.swift
//
//
//  Created by Jan Schwarz on 26.03.2021.
//

import Foundation

/// A type that is able to register a dependency that needs two variable arguments in order to be resolved later
public protocol DependencyWithTwoArgumentsRegistering: DependencyRegistering {
    /// Factory closure that instantiates the required dependency with two given variable arguments
    typealias FactoryWithTwoArguments<Dependency, Argument1, Argument2> = (DependencyWithOneArgumentResolving, Argument1, Argument2) -> Dependency

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
    func register<Dependency, Argument1, Argument2>(type: Dependency.Type, factory: @escaping FactoryWithTwoArguments<Dependency, Argument1, Argument2>)
}

// MARK: Overloaded factory methods
public extension DependencyWithTwoArgumentsRegistering {
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
    func register<Dependency, Argument1, Argument2>(factory: @escaping FactoryWithTwoArguments<Dependency, Argument1, Argument2>) {
        register(type: Dependency.self, factory: factory)
    }
}
