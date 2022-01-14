//
//  RegistrationIdentfier.swift
//  
//
//  Created by Jan Schwarz on 25.03.2021.
//

import Foundation

/// Object that uniquely identifies a registered dependency
struct RegistrationIdentfier {
    let typeIdentifier: ObjectIdentifier
    let argumentIdentifier: ObjectIdentifier?
    
    init<Dependency, Argument>(type: Dependency.Type, argument: Argument.Type) {
        self.typeIdentifier = ObjectIdentifier(type)
        self.argumentIdentifier = ObjectIdentifier(type)
    }
    
    init<Dependency>(type: Dependency.Type) {
        self.typeIdentifier = ObjectIdentifier(type)
        self.argumentIdentifier = nil
    }
}

// MARK: Hashable
extension RegistrationIdentfier: Hashable {}

// MARK: Debug information
extension RegistrationIdentfier: CustomStringConvertible {
    var description: String {
        """
        Type: \(typeIdentifier.debugDescription)
        Argument: \(argumentIdentifier?.debugDescription ?? "nil")
        """
    }
}
