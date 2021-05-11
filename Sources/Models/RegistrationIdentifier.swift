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
    
    init<T, Argument>(type: T.Type, argument: Argument.Type) {
        self.typeIdentifier = ObjectIdentifier(type)
        self.argumentIdentifiers = ObjectIdentifier(type)
    }
    
    init<T>(type: T.Type) {
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
