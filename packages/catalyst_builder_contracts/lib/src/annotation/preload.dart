import '../service_provider.dart';

/// Mark a singleton service as preloaded.
/// Preload means that an instance of the service
/// is created inside the [ServiceProvider.boot].
class Preload {
  /// Creates a new preload annotation.
  const Preload();
}
