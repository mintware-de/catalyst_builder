import 'abstract_service_container.dart';

/// A child container with an own lifetime.
///
/// A scope is created with `createScope()` on an
/// [AbstractServiceContainer]. It inherits all registrations of its
/// parent but can add its own services and parameters that stay invisible
/// to the parent. Services with [ServiceLifetime.scoped] are instantiated
/// once per scope.
abstract interface class ServiceScope implements AbstractServiceContainer {
  /// The container this scope was created from.
  ///
  /// For the root container this is the container itself.
  AbstractServiceContainer get parent;

  /// True if [dispose] was already called on this scope.
  bool get isDisposed;

  /// Disposes all [Disposable] instances that were created inside this
  /// scope, in reverse order of their creation, and marks the scope as
  /// disposed. Any further use of the scope throws a
  /// [ScopeDisposedException].
  ///
  /// Calling [dispose] multiple times is a no-op. Disposing a parent does
  /// **not** dispose the scopes created from it – scopes belong to whoever
  /// created them.
  @override
  Future<void> dispose();
}
