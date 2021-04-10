
enum ServiceLifetime {
  /// Every time the service is requested, a new instance will be created.
  transient,

  /// Only one instance of the service will be registered in
  /// the service container.
  singleton,
}
