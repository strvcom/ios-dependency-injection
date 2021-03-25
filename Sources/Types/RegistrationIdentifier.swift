//
//  RegistrationIdentfier.swift
//  
//
//  Created by Jan on 25.03.2021.
//

import Foundation

struct RegistrationIdentfier {
    let identifier: ObjectIdentifier
    
    init<T>(type: T.Type) {
        self.identifier = ObjectIdentifier(type)
    }
}

// MARK: Hashable
extension RegistrationIdentfier: Hashable {
    static func == (lhs: RegistrationIdentfier, rhs: RegistrationIdentfier) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

// MARK: Debug information
extension RegistrationIdentfier: CustomStringConvertible {
    var description: String {
        identifier.debugDescription
    }
}
