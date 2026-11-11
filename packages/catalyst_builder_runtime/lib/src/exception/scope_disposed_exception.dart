import 'catalyst_builder_exception.dart';

/// An exception that is thrown when a service is requested from a scope
/// that was already disposed.
class ScopeDisposedException extends CatalystBuilderException {
  /// Creates a new [ScopeDisposedException] object.
  const ScopeDisposedException()
      : super('This scope has already been disposed.');
}
