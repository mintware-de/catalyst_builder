import 'catalyst_builder_exception.dart';

/// An exception that is thrown when boot is called on a
/// already booted ServiceProvider.
class ContainerAlreadyBootedException extends CatalystBuilderException {
  /// Creates a new [ContainerAlreadyBootedException] object.
  const ContainerAlreadyBootedException()
      : super(
          'The service provider was already booted.',
        );
}
