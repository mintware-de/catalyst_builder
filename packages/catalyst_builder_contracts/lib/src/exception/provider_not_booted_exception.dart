import 'catalyst_builder_exception.dart';

/// An exception that is thrown when resolving services on a not booted
/// ServiceProvider.
class ProviderNotBootedException extends CatalystBuilderException {
  /// Creates a new [ProviderNotBootedException] object.
  const ProviderNotBootedException()
      : super(
          'Service provider was not booted. Call ServiceProvider.boot() first.',
        );
}
