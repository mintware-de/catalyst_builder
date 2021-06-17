import 'package:code_builder/code_builder.dart' as cb;

import '../../symbols.dart';

/// Template for _knownServices
final knownServicesTemplate = cb.Field((f) {
  f
    ..name = knownServices$.symbol
    ..modifier = cb.FieldModifier.final$
    ..assignment = cb.literalMap({}, typeT, serviceDescriptorT).code;
});
