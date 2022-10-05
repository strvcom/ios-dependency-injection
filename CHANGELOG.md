# Dependency Injection Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)

__Sections__

 - `Added` for new features.
 - `Changed` for changes in existing functionality.
 - `Deprecated` for once-stable features removed in upcoming releases.
 - `Removed` for deprecated features removed in this release.
 - `Fixed` for any bug fixes.

## [1.0.3]

### Fixed

- Container methods for registering and resolving dependencies were moved from extensions to the class body in order to make them overrideable
- 'APPLICATION_EXTENSION_API_ONLY' flag was added in order to get rid of warnings in app extensions


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
