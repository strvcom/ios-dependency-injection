# AGENTS.md

`DependencyInjection` is a zero-dependency Swift package providing a type-keyed dependency injection
container for Apple platforms. This file covers using it in app code. [README.md](README.md) has
installation and every API in full; [CONTRIBUTING.md](CONTRIBUTING.md) covers changing the package.

**Prefer `AsyncContainer` in new code.** It is an `actor`, so it is data-race safe under the Swift 6
language mode, with compiler-enforced `Sendable` bounds. `Container` is `@unchecked Sendable` over
unguarded dictionaries — that silences the concurrency checker rather than proving anything. Use
`Container` only for `@Injected` / `@LazyInjected` or `autoregister`, which the async side lacks, and
confine it to one isolation domain. Examples below are `Container` unless marked otherwise.

## Composition root

One `ModuleRegistration` per feature module, all called once at launch before anything resolves.

```swift
enum NetworkingModule: ModuleRegistration {
    static func registerDependencies(in container: Container) {
        container.register(type: APIClient.self, dependency: URLSessionAPIClient())
        container.autoregister(in: .shared, initializer: TokenStore.init)
    }
}

enum AppDependencies {
    static func configure(in container: Container = .shared) {
        NetworkingModule.registerDependencies(in: container)
    }
}
```

Call `configure()` from `App.init()` or `application(_:didFinishLaunchingWithOptions:)`. Registering
into `Container.shared` is what lets the property wrappers work without `from:`. New registrations go
in a module's `registerDependencies(in:)`, not scattered through the app.

## Register and resolve

```swift
container.register(type: APIClient.self, in: .shared) { resolver in
    URLSessionAPIClient(tokenStore: resolver.resolve(type: TokenStore.self))
}
container.register(type: AppConfiguration.self, dependency: .production)  // always shared
container.autoregister(in: .shared, initializer: ProfileRepository.init)  // parameters auto-resolved
let repository: ProfileRepository = container.resolve()
let checked = try container.tryResolve(type: ProfileRepository.self)
```

`.shared` caches the first instance forever; `.new` runs the factory on every resolve. **Always pass
`in:`** — `register { ... }` without a scope binds the variadic-argument overload, which hard-codes
`.new`. `resolve` is `try! tryResolve`, so an unregistered type **crashes the process**; use
`tryResolve` wherever the composition root does not guarantee the registration.

`@Injected` resolves at owner init, `@LazyInjected` at first access. Both default to
`Container.shared` and take `from:` to target another container.

## AsyncContainer

Same model with `await` throughout and `Sendable` required on every dependency and argument. The
`await` sits on the inner `resolve`, not on the factory closure.

```swift
enum NetworkingModule: AsyncModuleRegistration {
    static func registerDependencies(in container: AsyncContainer) async {
        await container.register(in: .shared) { resolver in
            URLSessionAPIClient(tokenStore: await resolver.resolve(type: TokenStore.self))
        }
    }
}
let client: URLSessionAPIClient = await AsyncContainer.shared.resolve()
```

There is no `autoregister` and no property wrappers on this side.

## Runtime arguments

`container.register { resolver, userID in ... }`, resolved with `container.resolve(arguments: "id")`.

- 1–3 arguments, always `.new` — there is no scope parameter.
- A fourth throws `ResolutionError.tooManyArguments` **at resolve time, not registration**, so an
  over-wide registration compiles and fails at runtime.
- Matching uses **compile-time** types: registering `any APIClient` and resolving a concrete
  `URLSessionAPIClient` throws `ResolutionError.unmatchingArgumentType`.

## Testing app code

Register into a local `Container()` per test rather than `Container.shared`, re-running the module's
`registerDependencies(in:)` and then overriding what the test needs. A test that does touch
`Container.shared` — the bare property wrappers do — must `clean()` before it returns, or the
registration leaks into every other test.

## Traps

- `Container` is **not thread-safe**; its storage is unguarded despite `@unchecked Sendable`.
- Re-registering a type discards its cached `.shared` instance. Anything holding the old one keeps it,
  so two objects can both believe they are the singleton. Register once at startup.
- `@LazyInjected` is a `final class`; struct copies share the wrapper and the resolved instance.
- `AsyncContainer` dedupes in-flight `.shared` resolution — N concurrent resolves run the factory once,
  and a throw clears the entry so the next resolve retries.
