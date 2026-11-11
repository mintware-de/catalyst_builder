part of '../public_api.dart';

/// A service with required parameters of a nullable type.
///
/// [ConsoleTransport] is registered in the container, so [transport] must be
/// resolved. [NotRegisteredService] is not registered, so [unregistered]
/// must be `null` – the factory must not throw for required nullable
/// parameters.
@Service()
class NullableDependencyService {
  /// Resolved from the container although the parameter type is nullable.
  final ConsoleTransport? transport;

  /// No service is registered for this type, so this stays `null`.
  final NotRegisteredService? unregistered;

  /// Creates a new [NullableDependencyService].
  const NullableDependencyService(this.transport, this.unregistered);
}

/// A class that is intentionally not registered as a service.
class NotRegisteredService {}
