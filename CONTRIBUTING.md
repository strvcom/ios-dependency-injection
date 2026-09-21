# Contributing

Development guide for `DependencyInjection`, and the contributor entry point for this repository.
[AGENTS.md](AGENTS.md) documents the package from the outside, for agents and developers building an
app with it; [README.md](README.md) covers the same ground in prose. Rules scoped to the code itself
live in [Sources/AGENTS.md](Sources/AGENTS.md) and [Tests/AGENTS.md](Tests/AGENTS.md) — read whichever
covers the files you are about to edit.

## Every change

- `swift test` is the authoritative check. Run it before reporting a change as working.
- A pull request changing more than 50 lines must also update `CHANGELOG.md`, or CI fails the build.
- A public API change updates `AGENTS.md` and `README.md` in the same pull request.

## Toolchain

The package has no dependencies and builds with SwiftPM alone. It declares
`swift-tools-version:5.9` and uses parameter packs, so Swift 5.9 / Xcode 15 is the floor.

`.mise.toml` pins the Ruby toolchain CI needs for Danger:

```sh
mise install          # Ruby 3.3 + danger 8.2
```

SwiftLint and SwiftFormat are configured (`.swiftlint.yml`, `.swiftformat`) but are **not installed
or run by CI** — they are local-only conveniences.

## Commands

```sh
swift build                           # compile the library
swift test                            # authoritative check — run this before claiming success
swift test --enable-code-coverage     # exactly what CI runs
danger --fail-on-errors=true          # CI only; needs GITHUB_TOKEN and an open pull request
swiftformat --lint .                  # report formatting drift without rewriting files
swiftlint --quiet                     # report lint findings
```

Two things that look like they should work but do not:

- **`xcodebuild test` has no test target to run.** `DependencyInjection.xcodeproj` exposes a single
  framework target and no tests. SwiftPM is the only path that runs the suite.
- **`swift package generate-documentation` is unavailable.** swift-docc-plugin is deliberately not a
  dependency. Build DocC from Xcode instead: Product → Build Documentation.

Do not run bare `swiftformat .`. It rewrites every file it touches, including ones unrelated to your
change.

## CI

`.github/workflows/integrations.yml` runs on every pull request, on a self-hosted macOS runner. It
installs Mise, runs Danger, then runs `swift test --enable-code-coverage`. That is the whole gate —
no linting, no formatting check, no coverage threshold.

`Dangerfile` fails the build when:

- a PR changes more than 50 lines without touching `CHANGELOG.md` (override by putting `#trivial` in
  the PR title or body, or `[WIP]` in the title), or
- the PR description is shorter than 5 characters.

## Public API compatibility

Everything under `Sources/` ships as public API. The package is past 1.0 — see `CHANGELOG.md` for the
current version — so changing an existing signature, argument label, or default value is a breaking
change: it needs a deliberate decision and a `CHANGELOG.md` entry under a new version heading. Adding
new overloads is fine; silently changing what an existing call resolves to is not.

## Container invariants

These are the behaviours that are easy to break, or to rely on incorrectly. Each is verified against
the current implementation.

**`Container` is not thread-safe.** It is declared `@unchecked Sendable`, but its `registrations` and
`sharedInstances` dictionaries are mutated without any lock. Concurrent `register`/`resolve` calls
from different threads are a data race and will corrupt the dictionaries or crash. Either register
everything from a single thread during startup, or use `AsyncContainer`, whose actor isolation makes
this safe.

**`resolve` traps; `tryResolve` throws.** `resolve` is `try! tryResolve` (see
`Sources/Protocols/Resolution/Sync/DependencyResolving.swift`). Resolving an unregistered type kills
the process. `@Injected` calls `resolve` during property-wrapper initialisation, so a missing
registration crashes when the enclosing object is created; `@LazyInjected` defers the same crash to
the first access of the property. Use `tryResolve` anywhere the registration is not guaranteed.

**Omitting `in:` registers `.new`, not `.shared`.** `register { ... }` with no scope binds the
variadic-argument overload with an empty parameter pack, which hard-codes `scope: .new`
(`Sources/Container/Sync/Container.swift`). Only `register(in: .shared)` and the autoclosure
`register(dependency:)` produce a cached instance. Always pass the scope explicitly.

**Re-registering a type discards its cached shared instance.** `register` sets
`sharedInstances[identifier] = nil`, because the new factory probably returns something different.
Anything already holding the previous instance keeps it, so two objects that both believe they are
the singleton can be alive at once. Register once at startup rather than re-registering later.

**The three-argument limit is enforced at resolve time, not at registration.** Registering a factory
with four arguments compiles and succeeds silently; only `tryResolve` checks
`RegistrationIdentifierConstant.maximumArgumentCount` and throws `ResolutionError.tooManyArguments`.
A registration that exceeds the limit is therefore dead code that fails at runtime.

**Argument matching uses compile-time types.** The registration key is built from the static types at
the call site, so registering with `any SomeProtocol` and resolving with a concrete conforming value
throws `ResolutionError.unmatchingArgumentType` even though the value conforms.

**`AsyncContainer` deduplicates in-flight shared resolution.** It keeps a `sharedTasks` map, so N
concurrent resolves of the same `.shared` type run the factory once and all await the same task. If
the factory throws, the task entry is cleared so the next resolve retries rather than caching the
failure.

## Testing

Tests use Swift Testing (`@Suite` / `@Test` / `#expect`) and live under `Tests/`. Scoped conventions
for writing them are in [Tests/AGENTS.md](Tests/AGENTS.md).

Expectations for a change:

- Sync and async behaviour is tested in parallel suites. A behaviour change on one side normally
  needs a matching case on the other.
- The package aims for full coverage of the public surface; new public behaviour should arrive with
  tests.
- `swift test` must pass before a change is reported as working.

## Documentation

Each document owns a distinct slice; keep changes in the one that owns the fact.

- **`README.md`** is the consumer source of truth: installation, registration, resolution, scopes,
  arguments, property wrappers. Every code block in it must compile against the current API — the
  examples went stale once already when parameter packs replaced the numbered `argument1:`/
  `argument2:` labels in 2.0.0.
- **`AGENTS.md`** is that same consumer surface condensed for coding agents: choosing a container, the
  `ModuleRegistration` composition root, scope rules, runtime arguments, testing app code, and the
  traps. It and `README.md` change together — a public API change that lands in one but not the other
  is a bug. Its code blocks must compile too.
- **DocC comments** on the declarations own per-symbol behaviour. Sync and async declarations carry
  deliberately duplicated comments; update both sides together.
- **`CHANGELOG.md`** follows [Keep a Changelog](http://keepachangelog.com/) and uses the section
  vocabulary listed at the top of the file. CI requires it for anything over 50 lines.

## Style

Formatting and lint rules are defined by `.swiftformat` and `.swiftlint.yml` — defer to those files
rather than to prose. Match the surrounding code where a rule does not apply.
