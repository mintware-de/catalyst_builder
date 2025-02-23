import 'service.dart';

/// This annotation can be used to create services without adding the
/// @Service annotation to the service itself.
class ServiceMap {
  /// The mapped services
  final Map<Type, Service> services;

  /// Creates a new service map
  const ServiceMap({
    required this.services,
  });
}
