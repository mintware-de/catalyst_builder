import 'package:code_builder/code_builder.dart' as cb;

import '../../symbols.dart';

/// Template for _booted
final bootedTemplate = cb.Field((f) {
  f
    ..name = booted$.symbol
    ..modifier = cb.FieldModifier.var$
    ..assignment = cb.literalFalse.code;
});
