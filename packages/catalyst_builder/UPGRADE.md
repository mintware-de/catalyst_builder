# Upgrade guide: catalyst_builder 6.x → 7.x

catalyst_builder 7.0 is a major release. It splits the runtime from the code generator,
rebuilds `enhance()` as a real child container (**scopes**), adds the `scoped` service
lifetime, disposal and build-time validation — and fixes a number of long standing bugs.

This guide covers the upgrade from 6.x to 7.x. For upgrades from versions before 6.x
see the [wiki](https://github.com/mintware-de/catalyst_builder/wiki).

## 1. TL;DR checklist

For 90% of users these steps are enough:

1. Swap the dependencies in your `pubspec.yaml` (see [2. Dependencies](#2-dependencies)):
   add `catalyst_builder_runtime` as a regular dependency, move `catalyst_builder` to
   `dev_dependencies` and remove `catalyst_builder_contracts`.
2. Replace all imports (see [3. Imports](#3-imports)) with
   `package:catalyst_builder_runtime/catalyst_builder_runtime.dart`.
3. Regenerate the service container plugin (see [4. Regenerate the code](#4-regenerate-the-code)).
4. Replace calls to the removed `enhance()` with `createScope()` and dispose your scopes
   (see [5.3 enhance() has been removed](#53-enhance-has-been-removed--createscope)).

If the compiler complains afterwards, the [Breaking changes in detail](#5-breaking-changes-in-detail)
section explains why and shows the fix.

## 2. Dependencies

Before (6.x):

```yaml
dependencies:
  catalyst_builder: ^6.0.0
  catalyst_builder_contracts: ^2.1.0
dev_dependencies:
  build_runner: ^2.4.0
```

After (7.x):

```yaml
dependencies:
  catalyst_builder_runtime: ^7.0.0
dev_dependencies:
  build_runner: ^2.4.0
  catalyst_builder: ^7.0.0
```

`catalyst_builder` is now **only** the code generator and belongs into `dev_dependencies` —
your app no longer pulls `analyzer`, `dart_style` and friends into its production
dependency tree. The runtime (the `ServiceContainer`, the annotations and the interfaces)
lives in the new package `catalyst_builder_runtime`, which has no dependencies at all.
`catalyst_builder_contracts` is discontinued; remove it.

## 3. Imports

| 6.x | 7.x |
|---|---|
| `package:catalyst_builder/catalyst_builder.dart` | `package:catalyst_builder_runtime/catalyst_builder_runtime.dart` |
| `package:catalyst_builder_contracts/catalyst_builder_contracts.dart` | `package:catalyst_builder_runtime/catalyst_builder_runtime.dart` |

Both old imports map to the single new import.

Find and replace on Linux:

```bash
grep -rl "package:catalyst_builder/catalyst_builder.dart\|package:catalyst_builder_contracts/" lib bin test \
  | xargs sed -i "s+package:catalyst_builder/catalyst_builder.dart+package:catalyst_builder_runtime/catalyst_builder_runtime.dart+g; s+package:catalyst_builder_contracts/catalyst_builder_contracts.dart+package:catalyst_builder_runtime/catalyst_builder_runtime.dart+g"
```

On macOS (`sed -i` requires an empty backup suffix there):

```bash
grep -rl "package:catalyst_builder/catalyst_builder.dart\|package:catalyst_builder_contracts/" lib bin test \
  | xargs sed -i '' "s+package:catalyst_builder/catalyst_builder.dart+package:catalyst_builder_runtime/catalyst_builder_runtime.dart+g; s+package:catalyst_builder_contracts/catalyst_builder_contracts.dart+package:catalyst_builder_runtime/catalyst_builder_runtime.dart+g"
```

## 4. Regenerate the code

The generated `*.plugin.g.dart` files from 6.x are not compatible with the 7.x runtime.
Regenerate them:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 5. Breaking changes in detail

### 5.1 Singletons are built by the container that registered them

**What changed:** A singleton is instantiated with the container that registered it
(its *owner*) and cached there. Before, `enhance()` copied everything into a new
container and singletons were built with that container, which is why they could see
services that only existed inside the enhanced container.

**Who is affected:** Everyone whose `enhance()`d container resolved singletons that
depend on child-only services or parameters.

Before (6.x):

```dart
// Registered as singleton in the root container.
class Report {
  final Settings settings;

  Report(this.settings);
}

final container = ServiceContainer();
// ... applyPlugin(...) with the Report singleton ...
container.boot();

// Settings exists only in the enhanced container.
final enhanced = container.enhance(services: [
  LazyServiceDescriptor((_) => Settings()),
]);

// 6.x: worked — the copied container also contained Settings.
final report = enhanced.resolve<Report>();
```

After (7.x) the same code throws:

```text
One or more dependencies of Report was not found. (Parameter: settings)
```

because `Report` is registered in the root and built by the root, which cannot see
`Settings`. The fix is to give the depending service a lifetime that matches its
dependencies — `scoped` is the natural choice:

```dart
// Registered as a scoped service via @Service(lifetime: ServiceLifetime.scoped)
// or registered with Service(lifetime: ServiceLifetime.scoped).
class Report {
  final Settings settings;

  Report(this.settings);
}

final scope = container.createScope(services: [
  LazyServiceDescriptor((_) => Settings()),
]);
final report = scope.resolve<Report>(); // built by the scope, sees Settings
```

The same rule applies to parameters: a root singleton reads the **root's** parameters,
even when it is resolved from a scope.

### 5.2 A singleton that depends on a scoped service throws

**What changed:** `singleton → scoped` is a configuration error (a captive dependency)
and now throws a `ScopeRequiredException` instead of quietly leaking one scope's
instance into the whole application.

**Who is affected:** Users who upgrade and have (or add) such a dependency. The build
time validation already reports this pattern as a build error.

```dart
// @Service(lifetime: ServiceLifetime.scoped)
class Db {}

// @Service() — singleton
class Report {
  final Db db;

  Report(this.db);
}

container.resolve<Report>();
// throws: Service Db is scoped and must be resolved from a scope (createScope()).
```

Fix: make the depending service `scoped` (or `transient`) as well, or inject a factory
that resolves the scoped service from a scope.

### 5.3 `enhance()` has been removed → `createScope()`

**What changed:** `enhance()` has been removed. `createScope()` replaces it with the
same signature and identical semantics. Scopes implement the new `ServiceScope`
interface, which adds `parent`, `isDisposed` and `dispose()`.

Before (6.x):

```dart
final enhanced = container.enhance(
  services: [LazyServiceDescriptor((_) => MyService())],
  parameters: {'userId': '42'},
);
final svc = enhanced.resolve<MyService>();
```

After (7.x):

```dart
final scope = container.createScope(
  services: [LazyServiceDescriptor((_) => MyService())],
  parameters: {'userId': '42'},
);
final svc = scope.resolve<MyService>();
await scope.dispose(); // disposes all Disposable instances created in the scope
```

Scopes are children of their parent instead of copies, so creating one is cheap and the
parent never sees what you register inside the scope. Disposing a parent does **not**
dispose the scopes created from it — whoever creates a scope disposes it.

### 5.4 `ServiceLifetime` gained the value `scoped`

**Who is affected:** Code that switches exhaustively over `ServiceLifetime`.

```dart
switch (descriptor.service.lifetime) {
  case ServiceLifetime.singleton:
    // ...
  case ServiceLifetime.transient:
    // ...
  case ServiceLifetime.scoped:
    // ...
}
```

### 5.5 `ServiceDescriptor` factories receive the container

**Who is affected:** Only hand-written plugins and manual `ServiceDescriptor` usage.
`produce()` now takes the resolving container as its argument.

Before (6.x):

```dart
ServiceDescriptor(const Service(), () => MyService());
```

After (7.x):

```dart
ServiceDescriptor(const Service(), (c) => MyService());
```

`descriptor.produce()` became `descriptor.produce(container)`.

### 5.6 `ServiceContainerPlugin.provideKnownServices()` has no parameter

**Who is affected:** Only hand-written plugins.

Before (6.x):

```dart
@override
Map<Type, ServiceDescriptor> provideKnownServices(AbstractServiceContainer c) {
  return {MyService: ServiceDescriptor(const Service(), () => MyService())};
}
```

After (7.x):

```dart
@override
Map<Type, ServiceDescriptor> provideKnownServices() {
  return {MyService: ServiceDescriptor(const Service(), (c) => MyService())};
}
```

### 5.7 New required members on `AbstractServiceContainer`

**Who is affected:** Only custom `AbstractServiceContainer` implementations.

Add these two members to your existing implementation (all other members are
unchanged from 6.x):

```dart
@override
ServiceScope createScope({
  List<LazyServiceDescriptor> services = const [],
  Map<String, dynamic> parameters = const {},
}) {
  // ... return a child container/scope that delegates to this one ...
}

@override
Future<void> dispose() async {
  // ... dispose the instances this container owns (e.g. its singletons) ...
}
```

### 5.8 Behavior fixes you may notice

These are bug fixes, but they can change the behavior of existing code:

- **Required nullable constructor parameters are now resolved.** For
  `class A { A(this.logger); final Logger? logger; }` the generator emitted a
  resolution for the type `Logger?`, which never matched the registered `Logger` and
  threw a `DependencyNotFoundException` even though the service was registered. It now
  resolves `Logger` and passes `null` only if it truly is unavailable.
- **The lifetime fallback of `@Service` is now `singleton`** (it was `transient` when
  the lifetime could not be read from the annotation), matching the annotation default.
- **`ServiceNotFoundException.service` reports the requested type.**
  `container.resolve<Object>(String)` now reports `String`, not `Object`.
- **Circular dependencies throw `CircularDependencyException`** (with the offending
  `path`) instead of causing a `StackOverflowError`.

## 6. New features

### Scoped services and `createScope()`

`ServiceLifetime.scoped` creates one instance per scope. The instance is reused inside
the scope and invisible to other scopes. Resolving a scoped service from the root
container throws `ScopeRequiredException`.

```dart
// @Service(lifetime: ServiceLifetime.scoped)
class RequestContext {}

final scope = container.createScope();
final a = scope.resolve<RequestContext>();
final b = scope.resolve<RequestContext>();
assert(identical(a, b)); // one instance per scope
```

### `Disposable` and `dispose()`

Instances created inside a scope that implement `Disposable` are disposed in reverse
creation order when the scope is disposed. The root container disposes its singletons
on `dispose()`. Disposal is idempotent; if one `dispose()` throws, the remaining
services are still disposed and the first error is rethrown.

```dart
// @Service(lifetime: ServiceLifetime.scoped)
class DatabaseSession implements Disposable {
  @override
  Future<void> dispose() async {
    // close the session
  }
}

final scope = container.createScope();
scope.resolve<DatabaseSession>();
await scope.dispose(); // disposes the DatabaseSession
```

### Circular dependency detection

The container keeps track of the services it is currently building. A cycle throws
`CircularDependencyException` with the full `path` instead of overflowing the stack.

```dart
try {
  container.resolve<A>();
} on CircularDependencyException catch (e) {
  print(e.path); // [A, B, A]
}
```

### Build time validation

The generator validates the service graph: circular dependencies and captive
dependencies (`singleton` → `scoped`) abort the build as errors; unknown required
dependency types and duplicate `exposeAs` are reported as warnings. The `validation`
option in your `build.yaml` controls the severity (`strict`, `warn` (default) or
`off`):

```yaml
targets:
  $default:
    builders:
      catalyst_builder:buildServiceContainerPlugin:
        options:
          validation: strict
```

## 7. Troubleshooting

| Message | Cause | Fix |
|---|---|---|
| `Service Db is scoped and must be resolved from a scope (createScope()).` (`ScopeRequiredException`) | A `scoped` service was resolved from the root container, or a root singleton depends on a `scoped` service (also thrown by `tryResolve`). | Resolve it from a `createScope()`d container, or change the lifetime of the depending service to `scoped`/`transient`. |
| `One or more dependencies of Report was not found. (Parameter: settings)` (`DependencyNotFoundException`) after the upgrade | The dependency is a root singleton that depended on a service/parameter that only exists in the enhanced container — see [5.1](#51-singletons-are-built-by-the-container-that-registered-them). | Register the dependency in the root as well, or make the depending service `scoped`/`transient`. |
| `This scope has already been disposed.` (`ScopeDisposedException`) | The scope was disposed but is still being used. | Create a new scope; dispose scopes only when you are done with them. |
| `Circular dependency detected: A -> B -> A` (`CircularDependencyException`) at runtime, or `Circular dependency: A -> B -> A` as a build error | Two or more services depend on each other. | Break the cycle, e.g. by injecting a factory or a `Lazy` wrapper. |
| `Singleton A depends on scoped B (captive dependency). Make A scoped/transient or inject a factory.` (build error) | A `singleton` depends on a `scoped` service. | See [5.2](#52-a-singleton-that-depends-on-a-scoped-service-throws). |
| `Target of URI doesn't exist: 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart'` | The contracts package was removed. | Replace the import with `package:catalyst_builder_runtime/catalyst_builder_runtime.dart` — see [3. Imports](#3-imports). |

---

For upgrades from versions before 6.x see the
[wiki](https://github.com/mintware-de/catalyst_builder/wiki).
