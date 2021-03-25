//
//  File.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

public protocol DependencyResolving {
    func resolve<T>(type: T.Type) -> T
}

public extension DependencyResolving {
    func resolve<T>() -> T {
        resolve(type: T.self)
    }
}
