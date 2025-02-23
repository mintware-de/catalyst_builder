import 'package:analyzer/dart/element/element.dart';

import 'constants.dart';

extension ElementAnnotationExtension on ElementAnnotation {
  /// Checks if the annotation is part of the catalyst_builder package.
  bool isLibraryAnnotation(String name) {
    if (element?.enclosingElement3?.name != name) {
      return false;
    }
    var packageUri = element!.library?.source.uri.toString();
    if (packageUri == null) {
      return false;
    }
    return packageUri.startsWith(oldAnnotationsPrefix) ||
        packageUri.startsWith(annotationsPrefix);
  }
}
