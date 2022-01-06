//
//  RegistrationIdentfier.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

struct RegistrationIdentfier {
    let typeIdentifier: ObjectIdentifier
    let argumentIdentifiers: ObjectIdentifier?
    
    init<Dependency, Argument>(type: Dependency.Type, argument: Argument.Type) {
        self.typeIdentifier = ObjectIdentifier(type)
        self.argumentIdentifiers = ObjectIdentifier(type)
    }
    
    init<Dependency>(type: Dependency.Type) {
        self.typeIdentifier = ObjectIdentifier(type)
        self.argumentIdentifiers = nil
    }
}

// MARK: Hashable
extension RegistrationIdentfier: Hashable {}

// MARK: Debug information
extension RegistrationIdentfier: CustomStringConvertible {
    var description: String {
        """
        Type: \(typeIdentifier.debugDescription)
        Argument: \(argumentIdentifiers?.debugDescription ?? "nil")
        """
    }
}
