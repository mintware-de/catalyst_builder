part of '../example.dart';

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
