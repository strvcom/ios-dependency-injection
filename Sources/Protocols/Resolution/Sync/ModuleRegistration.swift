//
//  ModuleRegistration.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 19.12.2024.
//

/// Protocol used to enforce common naming of registration in a module.
public protocol ModuleRegistration {
    static func registerDependencies(in container: Container)
}
