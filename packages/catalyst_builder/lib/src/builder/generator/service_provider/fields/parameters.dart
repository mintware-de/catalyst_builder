import 'package:code_builder/code_builder.dart' as cb;

import '../../symbols.dart';

/// Template for parameters
final parametersTemplate = cb.Field((f) {
  f
    ..name = parameters$.symbol
    ..modifier = cb.FieldModifier.final$
    ..annotations.add(cb.refer('override'))
    ..assignment = cb.literalMap({}, stringT, dynamicT).code;
});
