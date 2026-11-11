/// Describes the lifetime of a service.
enum ServiceLifetime {
  /// Only one instance of the service will be registered in
  /// the service container.
  singleton,

  /// Every time the service is requested, a new instance will be created.
  transient,
}
