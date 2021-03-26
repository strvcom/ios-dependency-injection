//
//  File.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

public protocol DependencyResolving {
    func tryResolve<T>(type: T.Type, with identifier: String?) throws -> T
}

public extension DependencyResolving {
    func resolve<T>(type: T.Type, with identifier: String?) -> T {
        do {
            return try tryResolve(type: type, with: identifier)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func resolve<T>(type: T.Type) -> T {
        resolve(type: type, with: nil)
    }
    
    func resolve<T>(with identifier: String?) -> T {
        resolve(type: T.self, with: identifier)
    }

    func resolve<T>() -> T {
        resolve(type: T.self, with: nil)
    }
}
