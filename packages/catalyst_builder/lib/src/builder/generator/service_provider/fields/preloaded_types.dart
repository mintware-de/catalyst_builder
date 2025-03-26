import 'package:code_builder/code_builder.dart' as cb;

import '../../symbols.dart';

/// Template for _preloadedTypes
final preloadedTypesTemplate = cb.Field((f) {
  f
    ..name = preloadedTypes$.symbol
    ..modifier = cb.FieldModifier.final$
    ..assignment = cb.literalList([], typeT).code;
});
