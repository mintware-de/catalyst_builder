part of '../public_api.dart';

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
