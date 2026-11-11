import 'abstract_service_container.dart';
import 'annotation/annotation.dart';

/// A function that can produce a [T]. Dependencies can be resolved using the
/// passed [AbstractServiceContainer].
typedef ServiceFactory<T> = T Function(AbstractServiceContainer);

/// Describes a class for registering services
abstract interface class ServiceRegistry {
  /// Register a service
  void register<T>(
    ServiceFactory<T> factory, [
    Service service = const Service(),
  ]);
}
