import 'catalyst_builder_exception.dart';


/// An exception that is thrown when boot is called on a
/// already booted ServiceProvider.
class ProviderAlreadyBootedException extends CatalystBuilderException {
  /// Creates a new [ProviderAlreadyBootedException] object.
  const ProviderAlreadyBootedException()
      : super(
          'The service provider was already booted.',
        );
}
