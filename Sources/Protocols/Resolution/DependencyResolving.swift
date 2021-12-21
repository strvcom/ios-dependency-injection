//
//  File.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

public protocol DependencyResolving {
    /// Resolve a dependency that was previously registered
    /// - Parameters:
    ///   - type: Type of the dependency that should be resolved
    func tryResolve<T>(type: T.Type) throws -> T
}

public extension DependencyResolving {
    func resolve<T>(type: T.Type) -> T {
        try! tryResolve(type: type)
    }
    
    func resolve<T>() -> T {
        resolve(type: T.self)
    }
}
