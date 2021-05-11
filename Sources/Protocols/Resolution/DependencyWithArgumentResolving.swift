//
//  DependencyWithArgumentResolving.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import Foundation

public protocol DependencyWithArgumentResolving: DependencyResolving {
    /// Resolve a dependency that was previously registered
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    ///   - argument: Argument that will passed as an input parameter to the factory method
    func tryResolve<T, Argument>(type: T.Type, argument: Argument) throws -> T
}

public extension DependencyWithArgumentResolving {
    func resolve<T, Argument>(type: T.Type, argument: Argument) -> T {
        do {
            return try tryResolve(type: type, argument: argument)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func resolve<T, Argument>(argument: Argument) -> T {
        resolve(type: T.self, argument: argument)
    }
}
