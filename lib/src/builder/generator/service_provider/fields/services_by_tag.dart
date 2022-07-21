import 'package:code_builder/code_builder.dart' as cb;

import '../../symbols.dart';

/// Template for _servicesByTag
final servicesByTagTemplate = cb.Field((f) {
  f
    ..name = servicesByTag$.symbol
    ..modifier = cb.FieldModifier.final$
    ..assignment = cb.literalMap({}, symbolT, listOfT(typeT)).code;
});
