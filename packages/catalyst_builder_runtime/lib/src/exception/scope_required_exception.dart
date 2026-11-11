import 'catalyst_builder_exception.dart';

/// An exception that is thrown when a service with
/// [ServiceLifetime.scoped] was requested from the root container.
///
/// Scoped services must be resolved from a scope that was created with
/// `createScope()`. This is a configuration error and is also thrown by
/// `tryResolve`.
class ScopeRequiredException extends CatalystBuilderException {
  /// The type of the scoped [service] that was requested.
  final Type service;

  /// Creates a new [ScopeRequiredException] object.
  const ScopeRequiredException(this.service)
      : super(
          'Service $service is scoped and must be resolved from a scope '
          '(createScope()).',
        );
}
