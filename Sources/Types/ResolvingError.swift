//
//  ResolvingError.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import Foundation

public enum ResolvingError: Error {
    case dependencyNotRegistered(message: String)
    case unmatchingType(message: String)
    
    var localizedDescription: String {
        switch self {
        case .dependencyNotRegistered(let message):
            return message
        case .unmatchingType(let message):
            return message
        }
    }
}
