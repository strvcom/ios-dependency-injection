//
//  File.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

public protocol DependencyResolving {
    func tryResolve<T>(type: T.Type) throws -> T
}

public extension DependencyResolving {
    func resolve<T>(type: T.Type) -> T {
        do {
            return try tryResolve(type: type)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func resolve<T>() -> T {
        resolve(type: T.self)
    }
}
