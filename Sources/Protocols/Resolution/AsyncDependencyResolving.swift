//
//  AsyncDependencyResolving.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 17.12.2024.
//

import Foundation

/// A type that is able to resolve a dependency
public protocol AsyncDependencyResolving {
    /// Resolve a dependency that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type, ``ResolutionError`` is thrown
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    func tryResolve<T>(type: T.Type) async throws -> T
    
    /// Resolve a dependency with a variable argument that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if an argument of a different type than expected is passed, ``ResolutionError`` is thrown
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - argument: Argument that will be passed as an input parameter to the factory method
    func tryResolve<T, Argument>(type: T.Type, argument: Argument) async throws -> T
}

public extension AsyncDependencyResolving {
    /// Resolve a dependency that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type, a runtime error occurs
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    func resolve<T>(type: T.Type) async -> T {
        try! await tryResolve(type: type)
    }
    
    /// Resolve a dependency that was previously registered within the container. A type of the required dependency is inferred from the return type
    ///
    /// If the container doesn't contain any registration for a dependency with the given type, a runtime error occurs
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    func resolve<T>() async -> T {
        await resolve(type: T.self)
    }
    
    /// Resolve a dependency with a variable argument that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if an argument of a different type than expected is passed, a runtime error occurs
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - argument: Argument that will be passed as an input parameter to the factory method
    func resolve<T, Argument>(type: T.Type, argument: Argument) async -> T {
        try! await tryResolve(type: type, argument: argument)
    }
    
    /// Resolve a dependency with a variable argument that was previously registered within the container. The type of the required dependency is inferred from the return type
    ///
    /// If the container doesn't contain any registration for a dependency with the given type or if an argument of a different type than expected is passed, a runtime error occurs
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - argument: Argument that will be passed as an input parameter to the factory method
    func resolve<T, Argument>(argument: Argument) async -> T {
        await resolve(type: T.self, argument: argument)
    }
}
