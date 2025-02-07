import 'package:analyzer/dart/element/element.dart';

import 'constants.dart';

extension ElementAnnotationExtension on ElementAnnotation {
  /// Checks if the annotation is part of the catalyst_builder package.
  bool isLibraryAnnotation(String name) {
    if (element?.enclosingElement3?.name != name) {
      return false;
    }
    return (element!.library?.source.uri
            .toString()
            .startsWith(annotationsPrefix) ??
        false);
  }
}
