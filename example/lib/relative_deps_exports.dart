// If you've relative dependencies (local files) and they may change while running
// dart run build_runner watch --delete-conflicting-outputs
//
// you need this helper file. Export all libraries that contains used services.
export 'package:third_party_dependency/third_party_dependency.dart';
