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
    func tryResolve<Dependency>(type: Dependency.Type) throws -> Dependency

    /// Resolve a dependency with variable arguments that was previously registered within the container
    ///
    /// Uses Swift parameter packs to support 1-3 arguments with a single method signature.
    /// If the container doesn't contain any registration for a dependency with the given type
    /// or if arguments of different types than expected are passed, ``ResolutionError`` is thrown
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - arguments: Arguments that will be passed as input parameters to the factory method (1-3 arguments supported)
    func tryResolve<Dependency, each Argument>(type: Dependency.Type, _ arguments: repeat each Argument) throws -> Dependency
}

public extension DependencyResolving {
    /// Resolve a dependency that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type, a runtime error occurs
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    func resolve<Dependency>(type: Dependency.Type) -> Dependency {
        try! tryResolve(type: type)
    }

    /// Resolve a dependency that was previously registered within the container. A type of the required dependency is inferred from the return type
    ///
    /// If the container doesn't contain any registration for a dependency with the given type, a runtime error occurs
    func resolve<Dependency>() -> Dependency {
        resolve(type: Dependency.self)
    }

    /// Resolve a dependency with variable arguments that was previously registered within the container
    ///
    /// Uses Swift parameter packs to support 1-3 arguments with a single method signature.
    /// If the container doesn't contain any registration for a dependency with the given type
    /// or if arguments of different types than expected are passed, a runtime error occurs
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - arguments: Arguments that will be passed as input parameters to the factory method (1-3 arguments supported)
    func resolve<Dependency, each Argument>(type: Dependency.Type, _ arguments: repeat each Argument) -> Dependency {
        try! tryResolve(type: type, repeat each arguments)
    }

    /// Resolve a dependency with variable arguments that was previously registered within the container.
    /// The type of the required dependency is inferred from the return type.
    ///
    /// Uses Swift parameter packs to support 1-3 arguments with a single method signature.
    /// If the container doesn't contain any registration for a dependency with the given type
    /// or if arguments of different types than expected are passed, a runtime error occurs
    ///
    /// - Parameters:
    ///   - arguments: Arguments that will be passed as input parameters to the factory method (1-3 arguments supported)
    func resolve<Dependency, each Argument>(_ arguments: repeat each Argument) -> Dependency {
        resolve(type: Dependency.self, repeat each arguments)
    }
}
