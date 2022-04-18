import 'package:catalyst_builder/catalyst_builder.dart';

/// Describes a class for registering services
abstract class ServiceRegistry {
  /// Register a service
  void register<T>(
    T Function(ServiceProvider) factory, [
    Service service = const Service(),
  ]);
}
