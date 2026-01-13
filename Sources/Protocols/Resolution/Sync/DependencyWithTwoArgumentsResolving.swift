//
//  DependencyWithTwoArgumentsResolving.swift
//
//
//  Created by Jan Schwarz on 26.03.2021.
//

import Foundation

/// A type that is able to resolve a dependency with two given variable arguments
public protocol DependencyWithTwoArgumentsResolving: DependencyResolving {
    /// Resolve a dependency with two variable arguments that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if arguments of different types than expected are passed, ``ResolutionError`` is thrown
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - argument1: First argument that will be passed as an input parameter to the factory method
    ///   - argument2: Second argument that will be passed as an input parameter to the factory method
    func tryResolve<T, Argument1, Argument2>(type: T.Type, argument1: Argument1, argument2: Argument2) throws -> T
}

public extension DependencyWithTwoArgumentsResolving {
    /// Resolve a dependency with two variable arguments that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if arguments of different types than expected are passed, a runtime error occurs
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - argument1: First argument that will be passed as an input parameter to the factory method
    ///   - argument2: Second argument that will be passed as an input parameter to the factory method
    func resolve<T, Argument1, Argument2>(type: T.Type, argument1: Argument1, argument2: Argument2) -> T {
        try! tryResolve(type: type, argument1: argument1, argument2: argument2)
    }

    /// Resolve a dependency with two variable arguments that was previously registered within the container. The type of the required dependency is inferred from the return type
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if arguments of different types than expected are passed, a runtime error occurs
    ///
    /// - Parameters:
    ///   - argument1: First argument that will be passed as an input parameter to the factory method
    ///   - argument2: Second argument that will be passed as an input parameter to the factory method
    func resolve<T, Argument1, Argument2>(argument1: Argument1, argument2: Argument2) -> T {
        resolve(type: T.self, argument1: argument1, argument2: argument2)
    }
}
