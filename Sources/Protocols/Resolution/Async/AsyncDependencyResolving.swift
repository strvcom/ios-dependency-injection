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
    func tryResolve<Dependency: Sendable>(type: Dependency.Type) async throws -> Dependency

    /// Resolve a dependency with variable arguments that was previously registered within the container
    ///
    /// Uses Swift parameter packs to support 1-3 arguments with a single method signature.
    /// If the container doesn't contain any registration for a dependency with the given type
    /// or if arguments of different types than expected are passed, ``ResolutionError`` is thrown
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - arguments: Arguments that will be passed as input parameters to the factory method (1-3 arguments supported)
    func tryResolve<Dependency: Sendable, each Argument: Sendable>(type: Dependency.Type, _ arguments: repeat each Argument) async throws -> Dependency
}

public extension AsyncDependencyResolving {
    /// Resolve a dependency that was previously registered within the container
    ///
    /// If the container doesn't contain any registration for a dependency with the given type, a runtime error occurs
    ///
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    func resolve<Dependency: Sendable>(type: Dependency.Type) async -> Dependency {
        try! await tryResolve(type: type)
    }

    /// Resolve a dependency that was previously registered within the container. A type of the required dependency is inferred from the return type
    ///
    /// If the container doesn't contain any registration for a dependency with the given type, a runtime error occurs
    func resolve<Dependency: Sendable>() async -> Dependency {
        await resolve(type: Dependency.self)
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
    func resolve<Dependency: Sendable, each Argument: Sendable>(type: Dependency.Type, _ arguments: repeat each Argument) async -> Dependency {
        try! await tryResolve(type: type, repeat each arguments)
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
    func resolve<Dependency: Sendable, each Argument: Sendable>(_ arguments: repeat each Argument) async -> Dependency {
        await resolve(type: Dependency.self, repeat each arguments)
    }
}
