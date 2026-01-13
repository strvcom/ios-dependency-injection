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
    let argumentIdentifiers: [ObjectIdentifier]

    init<Dependency, Argument>(type: Dependency.Type, argument _: Argument.Type) {
        typeIdentifier = ObjectIdentifier(type)
        argumentIdentifiers = [ObjectIdentifier(Argument.self)]
    }

    init<Dependency, Argument1, Argument2>(type: Dependency.Type, argument1 _: Argument1.Type, argument2 _: Argument2.Type) {
        typeIdentifier = ObjectIdentifier(type)
        argumentIdentifiers = [ObjectIdentifier(Argument1.self), ObjectIdentifier(Argument2.self)]
    }

    init<Dependency, Argument1, Argument2, Argument3>(type: Dependency.Type, argument1 _: Argument1.Type, argument2 _: Argument2.Type, argument3 _: Argument3.Type) {
        typeIdentifier = ObjectIdentifier(type)
        argumentIdentifiers = [ObjectIdentifier(Argument1.self), ObjectIdentifier(Argument2.self), ObjectIdentifier(Argument3.self)]
    }

    init<Dependency>(type: Dependency.Type) {
        typeIdentifier = ObjectIdentifier(type)
        argumentIdentifiers = []
    }
}

// MARK: Hashable
extension RegistrationIdentifier: Hashable {}

// MARK: Debug information
extension RegistrationIdentifier: CustomStringConvertible {
    var description: String {
        let argumentsDescription: String
        if argumentIdentifiers.isEmpty {
            argumentsDescription = "nil"
        } else {
            argumentsDescription = argumentIdentifiers.map { $0.debugDescription }.joined(separator: ", ")
        }
        return """
        Type: \(typeIdentifier.debugDescription)
        Arguments: \(argumentsDescription)
        """
    }
}
