# Dependency Injection

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
- [Synchronous Container](#synchronous-container)
- [Asynchronous Container](#asynchronous-container)
- [Registration](#registration)
- [Resolution](#resolution)
- [Autoregistration](#autoregistration)
- [Property Wrappers](#property-wrappers)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)
- [API Reference](#api-reference)

## Requirements

- iOS/iPadOS 13.0+, macOS 10.15+, watchOS 6.0+, tvOS 13.0+
- Xcode 11+
- Swift 5.3+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/strvcom/ios-dependency-injection.git", .upToNextMajor(from: "1.0.0"))
]
```

Or add it through Xcode:
1. File → Add Packages...
2. Enter the repository URL: `https://github.com/strvcom/ios-dependency-injection.git`
3. Select the version rule and add to your target

## Quick Start

```swift
import DependencyInjection

// Create a container
let container = Container()

// Register a dependency
container.register { resolver in
    MyService(
        apiClient: resolver.resolve(type: APIClient.self)
    )
}

// Resolve the dependency
let service: MyService = container.resolve()
```

## Core Concepts

### Container

A container is the central component that manages dependencies. It stores registrations and provides instances when requested. The library provides two container types:

- **`Container`** - Synchronous container for traditional dependency injection
- **`AsyncContainer`** - Asynchronous container (actor-based) for Swift concurrency

### Factory

A factory is a closure or function that creates an instance of a dependency. Factories receive a resolver that can be used to resolve other dependencies.

### Scope

Dependencies can be registered with different scopes:

- **`.new`** - A new instance is created every time the dependency is resolved
- **`.shared`** - A single instance is created on first resolution and reused for all subsequent requests (singleton)

**Note:** Dependencies registered with variable arguments always use `.new` scope, as the behavior of shared instances with arguments is undefined.

### Variable Arguments

Sometimes a dependency requires parameters that can't be registered in the container (e.g., user input, configuration values). The library supports passing 1, 2, or 3 variable arguments during resolution.

## Synchronous Container

The `Container` class provides synchronous dependency injection for traditional Swift code.

### Creating a Container

```swift
// Create a new container
let container = Container()

// Or use the shared singleton
let container = Container.shared
```

### Basic Registration

```swift
// Register with explicit type and scope
container.register(type: MyService.self, in: .shared) { resolver in
    MyService(
        apiClient: resolver.resolve(type: APIClient.self)
    )
}

// Register with inferred type (default scope is .shared)
container.register { resolver in
    MyService(
        apiClient: resolver.resolve(type: APIClient.self)
    )
}

// Register with explicit scope
container.register(in: .new) { resolver in
    MyService(
        apiClient: resolver.resolve(type: APIClient.self)
    )
}
```

### Registration with Variable Arguments

The library supports registration with 1, 2, or 3 variable arguments:

```swift
// One argument
container.register { resolver, userId in
    UserService(userId: userId)
}

// Two arguments
container.register { resolver, userId, apiKey in
    AuthenticatedService(userId: userId, apiKey: apiKey)
}

// Three arguments
container.register { resolver, userId, apiKey, environment in
    ConfiguredService(userId: userId, apiKey: apiKey, environment: environment)
}
```

### Resolution

```swift
// Resolve without arguments
let service: MyService = container.resolve()
let service2 = container.resolve(type: MyService.self)

// Resolve with one argument
let userService: UserService = container.resolve(argument: "user123")
let userService2 = container.resolve(type: UserService.self, argument: "user123")

// Resolve with two arguments
let authService: AuthenticatedService = container.resolve(argument1: "user123", argument2: "key456")
let authService2 = container.resolve(type: AuthenticatedService.self, argument1: "user123", argument2: "key456")

// Resolve with three arguments
let configService: ConfiguredService = container.resolve(argument1: "user123", argument2: "key456", argument3: "production")
let configService2 = container.resolve(type: ConfiguredService.self, argument1: "user123", argument2: "key456", argument3: "production")
```

### Error Handling

```swift
// Using tryResolve (throws errors)
do {
    let service = try container.tryResolve(type: MyService.self)
    // Use service
} catch ResolutionError.dependencyNotRegistered(let message) {
    print("Dependency not registered: \(message)")
} catch {
    print("Unexpected error: \(error)")
}

// Using resolve (crashes on error - use with caution)
let service = container.resolve(type: MyService.self) // Will crash if not registered
```

## Asynchronous Container

The `AsyncContainer` is an actor-based container designed for Swift concurrency. All operations are `async` and thread-safe.

### Creating an Async Container

```swift
// Create a new async container
let container = AsyncContainer()

// Or use the shared singleton
let container = AsyncContainer.shared
```

### Basic Registration

```swift
// Register with explicit type and scope
await container.register(type: MyService.self, in: .shared) { resolver in
    await MyService(
        apiClient: await resolver.resolve(type: APIClient.self)
    )
}

// Register with inferred type (default scope is .shared)
await container.register { resolver in
    await MyService(
        apiClient: await resolver.resolve(type: APIClient.self)
    )
}
```

### Registration with Variable Arguments

```swift
// One argument
await container.register { resolver, userId in
    await UserService(userId: userId)
}

// Two arguments
await container.register { resolver, userId, apiKey in
    await AuthenticatedService(userId: userId, apiKey: apiKey)
}

// Three arguments
await container.register { resolver, userId, apiKey, environment in
    await ConfiguredService(userId: userId, apiKey: apiKey, environment: environment)
}
```

### Resolution

```swift
// Resolve without arguments
let service: MyService = await container.resolve()
let service2 = await container.resolve(type: MyService.self)

// Resolve with one argument
let userService: UserService = await container.resolve(argument: "user123")
let userService2 = await container.resolve(type: UserService.self, argument: "user123")

// Resolve with two arguments
let authService: AuthenticatedService = await container.resolve(argument1: "user123", argument2: "key456")
let authService2 = await container.resolve(type: AuthenticatedService.self, argument1: "user123", argument2: "key456")

// Resolve with three arguments
let configService: ConfiguredService = await container.resolve(argument1: "user123", argument2: "key456", argument3: "production")
let configService2 = await container.resolve(type: ConfiguredService.self, argument1: "user123", argument2: "key456", argument3: "production")
```

### Error Handling

```swift
// Using tryResolve (throws errors)
do {
    let service = try await container.tryResolve(type: MyService.self)
    // Use service
} catch ResolutionError.dependencyNotRegistered(let message) {
    print("Dependency not registered: \(message)")
} catch {
    print("Unexpected error: \(error)")
}
```

## Registration

### Registration Methods

The library provides multiple ways to register dependencies:

#### 1. Basic Registration

```swift
container.register(type: MyService.self, in: .shared) { resolver in
    MyService()
}
```

#### 2. Registration with Inferred Type

```swift
container.register { resolver in
    MyService() // Type inferred from return type
}
```

#### 3. Registration with Autoclosure

For simple dependencies without sub-dependencies:

```swift
container.register(dependency: MyService())
```

#### 4. Registration with Variable Arguments

```swift
// One argument
container.register { resolver, argument in
    MyService(parameter: argument)
}

// Two arguments
container.register { resolver, arg1, arg2 in
    MyService(param1: arg1, param2: arg2)
}

// Three arguments
container.register { resolver, arg1, arg2, arg3 in
    MyService(param1: arg1, param2: arg2, param3: arg3)
}
```

### Factory Closure Parameters

Factory closures receive:
1. **Resolver** - Used to resolve other dependencies from the container
2. **Variable Arguments** (optional) - 1, 2, or 3 arguments passed during resolution

```swift
container.register { resolver, userId in
    UserService(
        userId: userId,                    // Variable argument
        apiClient: resolver.resolve(type: APIClient.self),  // Resolved dependency
        logger: resolver.resolve(type: Logger.self)         // Resolved dependency
    )
}
```

## Resolution

### Resolution Methods

The library provides multiple ways to resolve dependencies:

#### 1. Type Inference

```swift
let service: MyService = container.resolve()
```

#### 2. Explicit Type

```swift
let service = container.resolve(type: MyService.self)
```

#### 3. With Variable Arguments

```swift
// One argument
let service: UserService = container.resolve(argument: "user123")

// Two arguments
let service: AuthService = container.resolve(argument1: "user123", argument2: "key456")

// Three arguments
let service: ConfigService = container.resolve(argument1: "user123", argument2: "key456", argument3: "production")
```

### Error Handling

Use `tryResolve` for error handling:

```swift
// Synchronous
do {
    let service = try container.tryResolve(type: MyService.self)
} catch ResolutionError.dependencyNotRegistered(let message) {
    // Handle error
}

// Asynchronous
do {
    let service = try await container.tryResolve(type: MyService.self)
} catch ResolutionError.dependencyNotRegistered(let message) {
    // Handle error
}
```

## Autoregistration

Autoregistration eliminates boilerplate by automatically creating factories from initializers.

### Basic Autoregistration

```swift
// Instead of:
container.register { resolver in
    MyService(
        apiClient: resolver.resolve(type: APIClient.self)
    )
}

// You can write:
container.autoregister(initializer: MyService.init)
```

### Autoregistration with Multiple Parameters

```swift
// Autoregister with 1 parameter
container.autoregister(initializer: ServiceWithOneParam.init)

// Autoregister with 2 parameters
container.autoregister(initializer: ServiceWithTwoParams.init)

// Autoregister with 3 parameters
container.autoregister(initializer: ServiceWithThreeParams.init)

// Autoregister with 4 parameters
container.autoregister(initializer: ServiceWithFourParams.init)

// Autoregister with 5 parameters
container.autoregister(initializer: ServiceWithFiveParams.init)
```

### Autoregistration with Variable Arguments

```swift
// Autoregister with one variable argument
container.autoregister(argument: String.self, initializer: UserService.init)

// Autoregister with one variable argument and one resolved parameter
container.autoregister(argument: String.self, initializer: UserServiceWithDependency.init)

// The initializer parameter order matters:
// - Variable argument can be first: (String, APIClient) -> UserService
// - Variable argument can be last: (APIClient, String) -> UserService
// - Variable argument can be in the middle: (APIClient, String, Logger) -> UserService
```

### Autoregistration with Scope

```swift
// Autoregister with explicit scope
container.autoregister(in: .new, initializer: MyService.init)
container.autoregister(in: .shared, initializer: MyService.init)
```

## Property Wrappers

The library provides two property wrappers for convenient dependency injection.

### @Injected

Resolves the dependency immediately when the property is initialized:

```swift
class ViewController {
    @Injected var service: MyService
    @Injected(from: customContainer) var customService: MyService
    
    func viewDidLoad() {
        service.doSomething() // Already resolved
    }
}
```

### @LazyInjected

Resolves the dependency lazily when first accessed:

```swift
class ViewController {
    @LazyInjected var service: MyService
    @LazyInjected(from: customContainer) var customService: MyService
    
    func viewDidLoad() {
        service.doSomething() // Resolved here on first access
    }
}
```

**Note:** Property wrappers only work with `Container`, not `AsyncContainer`. They use `Container.shared` by default, or you can specify a custom container.

## Error Handling

### Resolution Errors

The library defines `ResolutionError` enum:

```swift
public enum ResolutionError: Error {
    /// No dependency with the required type is registered within the container
    case dependencyNotRegistered(message: String)
    
    /// The dependency with the required type is registered but the factory expects a different argument type
    case unmatchingArgumentType(message: String)
}
```

### Handling Errors

```swift
// Synchronous
do {
    let service = try container.tryResolve(type: MyService.self)
} catch ResolutionError.dependencyNotRegistered(let message) {
    print("Dependency not found: \(message)")
} catch ResolutionError.unmatchingArgumentType(let message) {
    print("Argument type mismatch: \(message)")
} catch {
    print("Unexpected error: \(error)")
}

// Asynchronous
do {
    let service = try await container.tryResolve(type: MyService.self)
} catch ResolutionError.dependencyNotRegistered(let message) {
    print("Dependency not found: \(message)")
} catch ResolutionError.unmatchingArgumentType(let message) {
    print("Argument type mismatch: \(message)")
} catch {
    print("Unexpected error: \(error)")
}
```

## Best Practices

### 1. Container Setup

Create and configure your container in a dedicated location:

```swift
class AppContainer {
    static let shared = Container()
    
    static func configure() {
        shared.autoregister(initializer: APIClient.init)
        shared.autoregister(initializer: UserService.init)
        shared.autoregister(initializer: DataService.init)
    }
}

// In your AppDelegate or App struct
AppContainer.configure()
```

### 2. Protocol-Based Registration

Register dependencies by protocol for better testability:

```swift
protocol APIClientProtocol {
    func fetchData() -> Data
}

class APIClient: APIClientProtocol {
    func fetchData() -> Data { /* ... */ }
}

// Register by protocol
container.register(type: APIClientProtocol.self) { resolver in
    APIClient()
}

// Resolve by protocol
let client: APIClientProtocol = container.resolve()
```

### 3. Scope Selection

- Use `.shared` for services, managers, and singletons
- Use `.new` for view models, controllers, and stateful objects

```swift
// Shared service
container.register(in: .shared) { resolver in
    NetworkService()
}

// New instance for each resolution
container.register(in: .new) { resolver in
    ViewModel()
}
```

### 4. Variable Arguments

Use variable arguments for:
- User-specific data (user ID, session tokens)
- Configuration values determined at runtime
- Parameters that shouldn't be singletons

```swift
// Good: User-specific service
container.register { resolver, userId in
    UserProfileService(userId: userId)
}

// Avoid: Use resolved dependencies instead
container.register { resolver, userId in
    UserService(
        userId: userId,
        apiClient: resolver.resolve(type: APIClient.self) // Prefer this
    )
}
```

### 5. Async Container Usage

Use `AsyncContainer` when:
- Working with Swift concurrency (`async`/`await`)
- Dependencies require async initialization
- Thread safety is critical

```swift
let container = AsyncContainer.shared

await container.register { resolver in
    await DatabaseService.initialize()
}

let service = await container.resolve(type: DatabaseService.self)
```

### 6. Error Handling

Always use `tryResolve` in production code:

```swift
// Good
do {
    let service = try container.tryResolve(type: MyService.self)
    // Use service
} catch {
    // Handle error gracefully
}

// Avoid (crashes on error)
let service = container.resolve(type: MyService.self)
```

### 7. Testing

Create test containers with mock dependencies:

```swift
func testMyFeature() {
    let container = Container()
    container.register { _ in MockAPIClient() }
    container.register { resolver in
        MyService(apiClient: resolver.resolve(type: APIClientProtocol.self))
    }
    
    let service: MyService = container.resolve()
    // Test with service
}
```

## API Reference

### Container

#### Methods

- `register<Dependency>(type:in:factory:)` - Register a dependency
- `register<Dependency>(factory:)` - Register with inferred type
- `register<Dependency, Argument>(type:factory:)` - Register with one argument
- `register<Dependency, Argument1, Argument2>(type:factory:)` - Register with two arguments
- `register<Dependency, Argument1, Argument2, Argument3>(type:factory:)` - Register with three arguments
- `tryResolve<T>(type:)` - Resolve dependency (throws)
- `tryResolve<T, Argument>(type:argument:)` - Resolve with one argument (throws)
- `tryResolve<T, Argument1, Argument2>(type:argument1:argument2:)` - Resolve with two arguments (throws)
- `tryResolve<T, Argument1, Argument2, Argument3>(type:argument1:argument2:argument3:)` - Resolve with three arguments (throws)
- `resolve<T>(type:)` - Resolve dependency (crashes on error)
- `resolve<T>()` - Resolve with type inference (crashes on error)
- `resolve<T, Argument>(type:argument:)` - Resolve with one argument (crashes on error)
- `resolve<T, Argument>(argument:)` - Resolve with one argument, type inferred (crashes on error)
- `resolve<T, Argument1, Argument2>(type:argument1:argument2:)` - Resolve with two arguments (crashes on error)
- `resolve<T, Argument1, Argument2>(argument1:argument2:)` - Resolve with two arguments, type inferred (crashes on error)
- `resolve<T, Argument1, Argument2, Argument3>(type:argument1:argument2:argument3:)` - Resolve with three arguments (crashes on error)
- `resolve<T, Argument1, Argument2, Argument3>(argument1:argument2:argument3:)` - Resolve with three arguments, type inferred (crashes on error)
- `autoregister<Dependency>(type:in:initializer:)` - Autoregister dependency
- `autoregister<Dependency, Argument>(type:argument:initializer:)` - Autoregister with variable argument
- `clean()` - Remove all registrations and shared instances
- `releaseSharedInstances()` - Remove cached shared instances

### AsyncContainer

#### Methods

All methods are `async` and follow the same pattern as `Container`:

- `register<Dependency>(type:in:factory:) async` - Register a dependency
- `register<Dependency>(factory:) async` - Register with inferred type
- `register<Dependency, Argument>(type:factory:) async` - Register with one argument
- `register<Dependency, Argument1, Argument2>(type:factory:) async` - Register with two arguments
- `register<Dependency, Argument1, Argument2, Argument3>(type:factory:) async` - Register with three arguments
- `tryResolve<T>(type:) async throws` - Resolve dependency (throws)
- `tryResolve<T, Argument>(type:argument:) async throws` - Resolve with one argument (throws)
- `tryResolve<T, Argument1, Argument2>(type:argument1:argument2:) async throws` - Resolve with two arguments (throws)
- `tryResolve<T, Argument1, Argument2, Argument3>(type:argument1:argument2:argument3:) async throws` - Resolve with three arguments (throws)
- `resolve<T>(type:) async` - Resolve dependency (crashes on error)
- `resolve<T>() async` - Resolve with type inference (crashes on error)
- `resolve<T, Argument>(type:argument:) async` - Resolve with one argument (crashes on error)
- `resolve<T, Argument>(argument:) async` - Resolve with one argument, type inferred (crashes on error)
- `resolve<T, Argument1, Argument2>(type:argument1:argument2:) async` - Resolve with two arguments (crashes on error)
- `resolve<T, Argument1, Argument2>(argument1:argument2:) async` - Resolve with two arguments, type inferred (crashes on error)
- `resolve<T, Argument1, Argument2, Argument3>(type:argument1:argument2:argument3:) async` - Resolve with three arguments (crashes on error)
- `resolve<T, Argument1, Argument2, Argument3>(argument1:argument2:argument3:) async` - Resolve with three arguments, type inferred (crashes on error)
- `clean() async` - Remove all registrations and shared instances
- `releaseSharedInstances() async` - Remove cached shared instances

### DependencyScope

```swift
public enum DependencyScope: Sendable {
    case new      // New instance on each resolution
    case shared   // Singleton instance
}
```

### ResolutionError

```swift
public enum ResolutionError: Error {
    case dependencyNotRegistered(message: String)
    case unmatchingArgumentType(message: String)
}
```

### Property Wrappers

#### @Injected

```swift
@Injected var dependency: MyService
@Injected(from: container) var dependency: MyService
```

#### @LazyInjected

```swift
@LazyInjected var dependency: MyService
@LazyInjected(from: container) var dependency: MyService
```

## Examples

### Complete Example: Sync Container

```swift
import DependencyInjection

// Define dependencies
protocol APIClientProtocol {
    func fetch() -> String
}

class APIClient: APIClientProtocol {
    func fetch() -> String { return "Data" }
}

class UserService {
    let apiClient: APIClientProtocol
    let userId: String
    
    init(apiClient: APIClientProtocol, userId: String) {
        self.apiClient = apiClient
        self.userId = userId
    }
}

// Setup container
let container = Container()
container.autoregister(initializer: APIClient.init)
container.register { resolver, userId in
    UserService(
        apiClient: resolver.resolve(type: APIClientProtocol.self),
        userId: userId
    )
}

// Use dependencies
let apiClient: APIClientProtocol = container.resolve()
let userService: UserService = container.resolve(argument: "user123")
```

### Complete Example: Async Container

```swift
import DependencyInjection

actor DatabaseService {
    static func initialize() async -> DatabaseService {
        // Async initialization
        return DatabaseService()
    }
}

class UserRepository {
    let db: DatabaseService
    
    init(db: DatabaseService) {
        self.db = db
    }
}

// Setup async container
let container = AsyncContainer.shared
await container.register { resolver in
    await DatabaseService.initialize()
}
await container.register { resolver in
    UserRepository(db: await resolver.resolve(type: DatabaseService.self))
}

// Use dependencies
let db = await container.resolve(type: DatabaseService.self)
let repo = await container.resolve(type: UserRepository.self)
```

### Example: Property Wrappers

```swift
import DependencyInjection

class ViewModel {
    @Injected var apiClient: APIClientProtocol
    @LazyInjected var analytics: AnalyticsService
    
    func loadData() {
        apiClient.fetch() // Already resolved
        analytics.track() // Resolved on first access
    }
}
```

## License

See [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.
