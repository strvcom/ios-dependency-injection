//
//  ResolutionError.swift
//  
//
//  Created by Jan Schwarz on 26.03.2021.
//

import Foundation

public enum ResolutionError: Error {
    case dependencyNotRegistered(message: String)
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
