//
//  DependencyWithArgumentResolving.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import Foundation

public protocol DependencyWithArgumentResolving: DependencyResolving {
    func tryResolve<T, Argument>(type: T.Type, with identifier: String?, argument: Argument) throws -> T
}

public extension DependencyWithArgumentResolving {
    func resolve<T, Argument>(type: T.Type, with identifier: String?, argument: Argument) -> T {
        do {
            return try tryResolve(type: type, with: identifier, argument: argument)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func resolve<T, Argument>(type: T.Type, argument: Argument) -> T {
        resolve(type: type, with: nil, argument: argument)
    }
    
    func resolve<T, Argument>(with identifier: String?, argument: Argument) -> T {
        resolve(type: T.self, with: identifier, argument: argument)
    }

    func resolve<T, Argument>(argument: Argument) -> T {
        resolve(type: T.self, with: nil, argument: argument)
    }
}
