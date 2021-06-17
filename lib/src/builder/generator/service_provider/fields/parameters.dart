import 'package:code_builder/code_builder.dart' as cb;

import '../../symbols.dart';

/// Template for parameters
final parametersTemplate = cb.Field((f) {
  f
    ..annotations.add(cb.refer('override'))
    ..name = parameters$.symbol
    ..modifier = cb.FieldModifier.final$
    ..assignment = cb.literalMap({}, stringT, dynamicT).code;
});
