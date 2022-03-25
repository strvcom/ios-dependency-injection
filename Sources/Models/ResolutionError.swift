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

    public var localizedDescription: String {
        switch self {
        case .dependencyNotRegistered(let message):
            return "Dependency not registered: \(message)"
        case .unmatchingArgumentType(let message):
            return "Unmatching argument type: \(message)"
        }
    }
}
