import 'catalyst_builder_exception.dart';

/// An exception that is thrown when resolving services on a not booted
/// ServiceContainer.
class ContainerNotBootedException extends CatalystBuilderException {
  /// Creates a new [ContainerNotBootedException] object.
  const ContainerNotBootedException()
      : super(
          'Service container was not booted. Call ServiceContainer.boot() first.',
        );
}
