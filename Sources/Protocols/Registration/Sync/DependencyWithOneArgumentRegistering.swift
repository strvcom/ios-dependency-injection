//
//  DependencyWithOneArgumentRegistering.swift
//
//
//  Created by Jan Schwarz on 26.03.2021.
//

import Foundation

/// A type that is able to register a dependency that needs a variable argument in order to be resolved later
public protocol DependencyWithOneArgumentRegistering: DependencyRegistering {
    /// Factory closure that instantiates the required dependency with the given variable argument
    typealias FactoryWithOneArgument<Dependency, Argument> = (DependencyWithOneArgumentResolving, Argument) -> Dependency

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
    func register<Dependency, Argument>(type: Dependency.Type, factory: @escaping FactoryWithOneArgument<Dependency, Argument>)
}

// MARK: Overloaded factory methods
public extension DependencyWithOneArgumentRegistering {
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
    func register<Dependency, Argument>(factory: @escaping FactoryWithOneArgument<Dependency, Argument>) {
        register(type: Dependency.self, factory: factory)
    }
}
