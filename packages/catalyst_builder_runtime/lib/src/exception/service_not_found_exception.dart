import 'catalyst_builder_exception.dart';

/// An exception that is thrown when a service of the type [service]
/// was not found.
class ServiceNotFoundException extends CatalystBuilderException {
  /// The type of the [service] that was not found.
  final Type service;

  /// Creates a new [ServiceNotFoundException] object.
  const ServiceNotFoundException(this.service)
      : super('Service $service not found.');
}
