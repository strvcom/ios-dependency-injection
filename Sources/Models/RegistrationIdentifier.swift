//
//  RegistrationIdentifier.swift
//
//
//  Created by Jan Schwarz on 25.03.2021.
//

import Foundation

/// Object that uniquely identifies a registered dependency
struct RegistrationIdentifier {
    let typeIdentifier: ObjectIdentifier
    let argumentIdentifier: ObjectIdentifier?

    init<Dependency, Argument>(type: Dependency.Type, argument _: Argument.Type) {
        typeIdentifier = ObjectIdentifier(type)
        argumentIdentifier = ObjectIdentifier(type)
    }

    init<Dependency>(type: Dependency.Type) {
        typeIdentifier = ObjectIdentifier(type)
        argumentIdentifier = nil
    }
}

// MARK: Hashable
extension RegistrationIdentifier: Hashable {}

// MARK: Debug information
extension RegistrationIdentifier: CustomStringConvertible {
    var description: String {
        """
        Type: \(typeIdentifier.debugDescription)
        Argument: \(argumentIdentifier?.debugDescription ?? "nil")
        """
    }
}
