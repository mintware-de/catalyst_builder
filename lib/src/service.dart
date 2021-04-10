import 'service_lifetime.dart';

class Service {
  /// The lifetime of the service
  final ServiceLifetime lifetime;

  /// An optional type how the service is exposed.
  /// This is useful if you create an interface and want to expose
  /// a concrete implementation with the type of a interface.
  final Type? exposeAs;

  const Service({
    this.lifetime = ServiceLifetime.singleton,
    this.exposeAs,
  });
}
