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
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    func resolve<T>() -> T {
        resolve(type: T.self)
    }
}
