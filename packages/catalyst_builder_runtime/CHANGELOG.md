## 7.0.0-beta.1

See the [upgrade guide](https://github.com/mintware-de/catalyst_builder/blob/main/packages/catalyst_builder/UPGRADE.md) for the full migration instructions.

### Breaking

- The package has been renamed from `catalyst_builder_contracts` to `catalyst_builder_runtime`.
  Update your imports to `package:catalyst_builder_runtime/catalyst_builder_runtime.dart` and add
  it as a regular dependency:

  ```yaml
  dependencies:
    catalyst_builder_runtime: ^7.0.0
  ```
- The `ServiceContainer` has been moved from `catalyst_builder` into this package. Import it from
  `catalyst_builder_runtime` instead of `catalyst_builder`.
- `ServiceDescriptor` factories now receive the resolving container:
  `ServiceDescriptor(const Service(), (c) => MyService(c.resolve<Foo>()))`.
  `ServiceDescriptor.produce()` became `produce(AbstractServiceContainer container)`.
- `ServiceContainerPlugin.provideKnownServices()` no longer receives the container as a
  parameter.
- `enhance()` has been removed and replaced by `createScope()` with identical semantics:
  it creates a child container linked to its parent instead of copying all registrations.
  Singletons are always built and cached by the container that registered them: a root
  singleton can no longer see child-only dependencies (it now throws
  `DependencyNotFoundException` like on the root). Services registered in a child stay
  invisible to the root.
- `ServiceLifetime` gained the value `scoped` (at the end of the enum). Code with an
  exhaustive `switch` over `ServiceLifetime` must handle the new case.
- `AbstractServiceContainer` gained the members `createScope()` and `dispose()`. Custom implementations of
  `AbstractServiceContainer` must implement the new members.

### Features

- New lifetime `ServiceLifetime.scoped`: one instance per scope, created and reused by the
  innermost scope that resolves it. Resolving a scoped service from the root container throws
  a `ScopeRequiredException` – also via `tryResolve`, because it is a configuration error.
- `AbstractServiceContainer.createScope()` creates a child scope (with optional service and
  parameter overrides). Scopes implement the new `ServiceScope` interface
  (`parent`, `isDisposed`, `dispose()`).
- New interface `Disposable`: instances created inside a scope that implement it are disposed
  in reverse creation order when the scope is disposed; the root container disposes its
  singletons on `dispose()`. Disposal is idempotent; all instances are disposed even if one
  throws, and the first error is rethrown.
- Circular dependencies between services are detected while instantiating and throw the new
  `CircularDependencyException` with the offending `path` (e.g. `[A, B, A]`).

### Fixes

- `ServiceNotFoundException` thrown by `resolve` now reports the runtime type that was
  passed as argument instead of the static generic type.

