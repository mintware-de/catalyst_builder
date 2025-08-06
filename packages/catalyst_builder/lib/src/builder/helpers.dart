import 'package:analyzer/dart/element/element.dart';

import 'constants.dart';

extension ElementAnnotationExtension on ElementAnnotation {
  /// Checks if the annotation is part of the catalyst_builder package.
  bool isLibraryAnnotation(String name) {
    if (element2?.enclosingElement2?.displayName != name) {
      return false;
    }
    var packageUri = element2!.library2?.uri.toString();
    if (packageUri == null) {
      return false;
    }
    return packageUri.startsWith(oldAnnotationsPrefix) ||
        packageUri.startsWith(annotationsPrefix);
  }
}
