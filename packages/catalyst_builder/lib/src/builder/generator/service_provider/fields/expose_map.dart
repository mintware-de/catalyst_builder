import 'package:code_builder/code_builder.dart' as cb;

import '../../symbols.dart';

/// Template for _exposeMap
final exposeMapTemplate = cb.Field((f) {
  f
    ..name = exposeMap$.symbol
    ..modifier = cb.FieldModifier.final$
    ..assignment = cb.literalMap({}, typeT, typeT).code;
});
