abstract class ManuallyWiredService {}

class ManuallyWiredServiceImplementation implements ManuallyWiredService {
  static bool shouldPreload = false;
  static bool wasPreloaded = false;

  ManuallyWiredServiceImplementation() {
    if (shouldPreload) {
      wasPreloaded = true;
    }
  }
}
