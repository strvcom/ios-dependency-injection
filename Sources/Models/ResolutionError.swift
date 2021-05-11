//
//  ResolutionError.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import Foundation

public enum ResolutionError: Error {
    case dependencyNotRegistered(message: String)
    case unmatchingDependencyType(message: String)
    case unmatchingArgumentType(message: String)

    var localizedDescription: String {
        switch self {
        case .dependencyNotRegistered(let message):
            return "Dependency not registered: \(message)"
        case .unmatchingDependencyType(let message):
            return "Unmatching dependency type: \(message)"
        case .unmatchingArgumentType(let message):
            return "Unmatching argument type: \(message)"
        }
    }
}
