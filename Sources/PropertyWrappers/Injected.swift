//
//  Injected.swift
//  
//
//  Created by Jan on 26.03.2021.
//

import Foundation

@propertyWrapper
public struct Injected<T> {
    public let wrappedValue: T

    public init(from container: Container = .shared, identifier: String? = nil) {
        wrappedValue = container.resolve(with: identifier)
    }
}