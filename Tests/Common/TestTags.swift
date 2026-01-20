//
//  TestTags.swift
//  DependencyInjection
//
//  Created on 19.12.2024.
//

import Testing

extension Tag {
    @Tag static var async: Tag
    @Tag static var sync: Tag
    @Tag static var base: Tag
    @Tag static var arguments: Tag
    @Tag static var complex: Tag
    @Tag static var autoregistration: Tag
    @Tag static var propertyWrappers: Tag
}
