//
//  DependencyResolving.swift
//
//
//  Created by Jan Schwarz on 25.03.2021.
//

import Foundation

/// A type that is able to resolve a dependency
public protocol DependencyResolving {
    /// Resolve a dependency that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type, ``ResolutionError`` is thrown
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    func tryResolve<T>(type: T.Type) throws -> T

    /// Resolve a dependency with a variable argument that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if an argument of a different type than expected is passed, ``ResolutionError`` is thrown
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - argument: Argument that will be passed as an input parameter to the factory method
    func tryResolve<T, Argument>(type: T.Type, argument: Argument) throws -> T

    /// Resolve a dependency with two variable arguments that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if arguments of different types than expected are passed, ``ResolutionError`` is thrown
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - arguments: Arguments that will be passed as an input parameters to the factory method
    func tryResolve<T, Argument1, Argument2>(type: T.Type, argument1: Argument1, argument2: Argument2) throws -> T

    /// Resolve a dependency with three variable arguments that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if arguments of different types than expected are passed, ``ResolutionError`` is thrown
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - arguments: Arguments that will be passed as an input parameters to the factory method
    func tryResolve<T, Argument1, Argument2, Argument3>(type: T.Type, argument1: Argument1, argument2: Argument2, argument3: Argument3) throws -> T
}

public extension DependencyResolving {
    /// Resolve a dependency that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type, a runtime error occurs
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    func resolve<T>(type: T.Type) -> T {
        try! tryResolve(type: type)
    }

    /// Resolve a dependency that was previously registered within the container. A type of the required dependency is inferred from the return type
    ///
    /// If the container doesn't contain any registration for a dependency with the given type, a runtime error occurs
    func resolve<T>() -> T {
        resolve(type: T.self)
    }

    /// Resolve a dependency with a variable argument that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if an argument of a different type than expected is passed, a runtime error occurs
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - argument: Argument that will be passed as an input parameter to the factory method
    func resolve<T, Argument>(type: T.Type, argument: Argument) -> T {
        try! tryResolve(type: type, argument: argument)
    }

    /// Resolve a dependency with a variable argument that was previously registered within the container. The type of the required dependency is inferred from the return type
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if an argument of a different type than expected is passed, a runtime error occurs
    ///
    /// - Parameters:
    ///   - argument: Argument that will be passed as an input parameter to the factory method
    func resolve<T, Argument>(argument: Argument) -> T {
        resolve(type: T.self, argument: argument)
    }

    /// Resolve a dependency with two variable arguments that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if arguments of different types than expected are passed, a runtime error occurs
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - arguments: Arguments that will be passed as an input parameters to the factory method
    func resolve<T, Argument1, Argument2>(type: T.Type, argument1: Argument1, argument2: Argument2) -> T {
        try! tryResolve(type: type, argument1: argument1, argument2: argument2)
    }

    /// Resolve a dependency with two variable arguments that was previously registered within the container. The type of the required dependency is inferred from the return type
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if arguments of different types than expected are passed, a runtime error occurs
    ///
    /// - Parameters:
    ///   - arguments: Arguments that will be passed as an input parameters to the factory method
    func resolve<T, Argument1, Argument2>(argument1: Argument1, argument2: Argument2) -> T {
        resolve(type: T.self, argument1: argument1, argument2: argument2)
    }

    /// Resolve a dependency with three variable arguments that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if arguments of different types than expected are passed, a runtime error occurs
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - arguments: Arguments that will be passed as an input parameters to the factory method
    func resolve<T, Argument1, Argument2, Argument3>(type: T.Type, argument1: Argument1, argument2: Argument2, argument3: Argument3) -> T {
        try! tryResolve(type: type, argument1: argument1, argument2: argument2, argument3: argument3)
    }

    /// Resolve a dependency with three variable arguments that was previously registered within the container. The type of the required dependency is inferred from the return type
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if arguments of different types than expected are passed, a runtime error occurs
    ///
    /// - Parameters:
    ///   - arguments: Arguments that will be passed as an input parameters to the factory method
    func resolve<T, Argument1, Argument2, Argument3>(argument1: Argument1, argument2: Argument2, argument3: Argument3) -> T {
        resolve(type: T.self, argument1: argument1, argument2: argument2, argument3: argument3)
    }
}
