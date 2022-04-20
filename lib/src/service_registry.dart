import 'package:catalyst_builder/catalyst_builder.dart';

/// A function that can produce a [T]. Dependencies can be resolved using the
/// passed [ServiceProvider].
typedef ServiceFactory<T> = T Function(ServiceProvider);

/// Describes a class for registering services
abstract class ServiceRegistry {
  /// Register a service
  void register<T>(
    ServiceFactory<T> factory, [
    Service service = const Service(),
  ]);
}
