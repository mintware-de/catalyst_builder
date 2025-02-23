import '../service_lifetime.dart';
import '../service_provider.dart';

/// This class represents a service that is registered in the [ServiceProvider].
class Service {
  /// The lifetime of the service
  final ServiceLifetime lifetime;

  /// An optional type how the service is exposed.
  /// This is useful if you create an interface and want to expose
  /// a concrete implementation with the type of a interface.
  final Type? exposeAs;

  /// Tags for this service. Tags can be used to group services together and
  /// receive all services in a specific groups from the ServiceProvider.
  final List<Symbol> tags;

  /// Creates a new service.
  /// The [lifetime] describes, if the service should be stored in the service
  /// provider after it's instantiated ([ServiceLifetime.singleton])
  /// or if always a fresh instance is created ([ServiceLifetime.transient]).
  const Service({
    this.lifetime = ServiceLifetime.singleton,
    this.exposeAs,
    this.tags = const <Symbol>[],
  });
}
