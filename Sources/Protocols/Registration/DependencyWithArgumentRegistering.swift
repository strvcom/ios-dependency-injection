//
//  DependencyWithArgumentRegistering.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import Foundation

public protocol DependencyWithArgumentRegistering: DependencyRegistering {
    typealias ResolverWithArgument<T, Argument> = (DependencyWithArgumentResolving, Argument) -> T
    
    /// Register a dependency with an argument
    ///
    /// The argument is typically a parameter in an initiliazer of the dependency that is not registered in the same resolver e.g. container,
    /// therefore, it needs to passed in `resolve` call
    ///
    /// DISCUSSION: This registration method doesn't have any scope parameter for a reason.
    /// The resolver should always return a new instance for dependencies with arguments as the behaviour for resolving shared instances with arguments is undefined.
    /// Should the argument conform to `Equatable` to compare the arguments to tell whether a shared instance with a given argument was already resolved?
    /// Shared instances are typically not dependent on variable input parameters by definition.
    /// If you need to support this usecase, please, keep references to the variable singletons outside of the resolver.
    /// - Parameters:
    ///   - type: Type of the dependency to register
    ///   - factory: Closure that is called once the dependency is being resolved
    func register<T, Argument>(type: T.Type, factory: @escaping ResolverWithArgument<T, Argument>)
}

// MARK: Overloaded factory methods
public extension DependencyWithArgumentRegistering {
    func register<T, Argument>(factory: @escaping ResolverWithArgument<T, Argument>) {
        register(type: T.self, factory: factory)
    }
}
