/// Describes a simple ServiceProvider
abstract class ServiceProvider {

  /// Resolves a [Service] of the given [T]ype.
  ///
  /// If the service does not exist, an [Exception] is thrown.
  T resolve<T>();

  /// Try to resolve a [Service] of the given [T]ype.
  ///
  /// If the service does not exist, null is returned.
  T? tryResolve<T>();
}
