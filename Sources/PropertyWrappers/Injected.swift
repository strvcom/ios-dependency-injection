//
//  Injected.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import Foundation

@propertyWrapper
public struct Injected<Dependency> {
    public let wrappedValue: Dependency

    public init(from container: Container = .shared) {
        wrappedValue = container.resolve(type: Dependency.self)
    }
}
