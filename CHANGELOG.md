# Dependency Injection Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)

__Sections__

 - `Added` for new features.
 - `Changed` for changes in existing functionality.
 - `Deprecated` for once-stable features removed in upcoming releases.
 - `Removed` for deprecated features removed in this release.
 - `Fixed` for any bug fixes.

## [Unreleased]

### Added

- **Agent-facing documentation** — `AGENTS.md` documents the package from the outside, for agents and developers building an app with it: the `ModuleRegistration` composition root, scope rules, resolution, runtime arguments, testing app code, and the runtime traps. Installation and requirements stay in `README.md`, which it links to. `CONTRIBUTING.md` carries the contributor workflow, build and test commands, public API compatibility, and the container invariants that are easy to break; `Sources/AGENTS.md` and `Tests/AGENTS.md` carry the rules scoped to those trees.
- **Guidance to prefer `AsyncContainer`** — `AGENTS.md` and `README.md` now recommend `AsyncContainer` for new code, especially under the Swift 6 language mode: it is an actor with compiler-enforced `Sendable` bounds, whereas `Container` is `@unchecked Sendable` over dictionaries it mutates without a lock, so the concurrency checker cannot catch a race. The trade-off — no `autoregister` and no property wrappers on the async side — is documented alongside it.
- **Documented `ModuleRegistration`** — `ModuleRegistration` and `AsyncModuleRegistration` are public API but were documented nowhere outside their own DocC comments. They are now documented as the composition-root pattern in `AGENTS.md`.

### Fixed

- **README examples now compile** — the resolution examples used the `argument:` and `argument1:`/`argument2:` labels removed in 2.0.0 and now use the parameter-pack `arguments:` parameter, and the argument-matching example annotated a closure parameter without the parentheses Swift requires.
- **Documented registration scope** — the README claimed `shared` was the default scope. Omitting `in:` selects the overload for registrations with arguments, which always registers with the `new` scope; the examples and the surrounding text now say so and pass the scope explicitly.
- **Stale requirements** — the README advertised Swift 5.3 and Xcode 11; the package requires Swift 5.9 and Xcode 15 because the container API is built on parameter packs. `.swift-version` was pinned to 5.3 for the same reason and now matches the manifest.
- **Installation snippet excluded every 2.x release** — the README pinned `.upToNextMajor(from: "1.0.0")`, which resolves to `>= 1.0.0, < 2.0.0` and therefore never reaches the current version. It now pins `2.0.0`.
- **Broken source link** — the `Factory` link in the README pointed at a path that moved when the sync and async protocols were split.

## [2.0.1]

### Added

- **Readable error messages** — `ResolutionError` messages now display human-readable Swift type names instead of raw `ObjectIdentifier` debug descriptions, making it easier to diagnose missing or mismatched registrations.

### Fixed

- **Argument type matching clarified** — Documented that argument matching is based on compile-time types, so registering with `ConcreteType` and resolving with `any Protocol` (or vice versa) creates distinct registrations.

## [2.0.0]

### Added

- Support for Swift parameter packs
- Tests converted to new Swift Testing framework

### Fixed

- Resolving of shared instances

## [1.0.5]

### Added

- Support for multiple arguments. Code clean up.
- Using parameter packs for multiple arguments
- Tests are converted to the new Swift Testing framework
- Fix of async resolve of shared dependencies

## [1.0.4]

### Fixed

- Async dependency injection fixes

## [1.0.3]

### Fixed

- Container methods for registering and resolving dependencies were moved from extensions to the class body in order to make them overrideable
- 'APPLICATION_EXTENSION_API_ONLY' flag was added in order to get rid of warnings in app extensions

### Added
- Support for async dependency injection

## [1.0.2]

### Added

- Method to remove already instantiated shared instances from the container


## [1.0.1]

### Added

- Swift and linker flags to suppress application extensions API warning

### Changed 

- Swift tools version updated to 5.6
- Main target name updated to a more friendly version


## [1.0.0]

### Added

- Register and resolve a shared instance
- Register and resolve a new instance
- Register an instance with an identifier
- Register an instance with arguments
- Convenient property wrapper
- Autoregister an instance i.e. possibility to specify only an initializer instead of manually initializing an instance in the resolving closure
- 100% test coverage
- Documentation
