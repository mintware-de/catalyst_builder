/// Describes the lifetime of a service.
enum ServiceLifetime {
  /// Only one instance of the service will be registered in
  /// the service container.
  singleton,

  /// Every time the service is requested, a new instance will be created.
  transient,

  /// One instance per scope.
  ///
  /// A scoped service is instantiated the first time it is requested
  /// inside a scope and reused for the lifetime of that scope. Resolving a
  /// scoped service from the root container throws a
  /// [ScopeRequiredException].
  scoped,
}
