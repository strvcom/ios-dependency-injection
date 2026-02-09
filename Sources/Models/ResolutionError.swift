//
//  ResolutionError.swift
//
//
//  Created by Jan Schwarz on 26.03.2021.
//

import Foundation

/// Errors that might occur when a dependency is being resolved
public enum ResolutionError: Error {
    /// No dependency with the required type is registered within the container
    case dependencyNotRegistered(message: String)

    /// The dependency with the required type is registered within the container but the factory closure expects a different argument type
    case unmatchingArgumentType(message: String)

    /// More than the maximum supported number of arguments (3) was passed to resolve
    case tooManyArguments(message: String)

    public var localizedDescription: String {
        switch self {
        case let .dependencyNotRegistered(message):
            return "Dependency not registered: \(message)"
        case let .unmatchingArgumentType(message):
            return "Unmatching argument type: \(message)"
        case let .tooManyArguments(message):
            return "Too many arguments: \(message)"
        }
    }
}
