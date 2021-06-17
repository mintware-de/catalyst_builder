import 'package:catalyst_builder/catalyst_builder.dart';

@Service()
@Preload()
class PreloadService {
  static bool shouldPreload = false;
  static bool wasPreloaded = false;
  PreloadService() {
    if (shouldPreload) {
      wasPreloaded = true;
    }
  }
}
