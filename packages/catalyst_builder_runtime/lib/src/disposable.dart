import 'dart:async';

/// Implemented by services that want to be released when the container or
/// scope that created them is disposed.
///
/// All instances created inside a scope that implement [Disposable] are
/// disposed – in reverse creation order – when the scope is disposed.
/// The root container disposes its singletons on `dispose()`.
abstract interface class Disposable {
  /// Releases the resources held by this service.
  FutureOr<void> dispose();
}
