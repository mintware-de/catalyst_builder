import 'catalyst_builder_exception.dart';

/// An exception that is thrown when a circular dependency between two or
/// more services is detected while they are instantiated.
class CircularDependencyException extends CatalystBuilderException {
  /// The chain of service types that leads back to the first service.
  ///
  /// For example `[A, B, A]` when `A` depends on `B` and `B` depends on
  /// `A` again.
  final List<Type> path;

  /// Creates a new [CircularDependencyException] object.
  CircularDependencyException(this.path)
      : super('Circular dependency detected: ${path.join(' -> ')}');
}
