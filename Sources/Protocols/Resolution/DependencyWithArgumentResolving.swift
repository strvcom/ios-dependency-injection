//
//  DependencyWithArgumentResolving.swift
//  
//
//  Created by Jan Schwarz on 26.03.2021.
//

import Foundation

/// A type that is able to resolve a dependency with a given variable argument
public protocol DependencyWithArgumentResolving: DependencyResolving {
    /// Resolve a dependency with a variable argument that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if an argument of a different type than expected is passed, ``ResolutionError`` is thrown
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - argument: Argument that will be passed as an input parameter to the factory method
    func tryResolve<T, Argument>(type: T.Type, argument: Argument) throws -> T
}

public extension DependencyWithArgumentResolving {
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
    
    /// Resolve a dependency with a variable argument that was previously registered within the container. A type of the required dependency is inferred from the return type
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if an argument of a different type than expected is passed, a runtime error occurs
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - argument: Argument that will be passed as an input parameter to the factory method
    func resolve<T, Argument>(argument: Argument) -> T {
        resolve(type: T.self, argument: argument)
    }
}
