//
//  ModileRegistration.swift
//  DependencyInjection
//
//  Created by Róbert Oravec on 17.12.2024.
//

/// Protocol used to enforce common naming of registration in a module.
public protocol AsyncModuleRegistration {
    static func registerDependencies(in container: AsyncContainer) async
}
