import 'package:code_builder/code_builder.dart' as cb;

import '../../symbols.dart';

/// Template for _serviceInstances
final serviceInstancesTemplate = cb.Field((f) {
  f
    ..name = serviceInstances$.symbol
    ..assignment = cb.literalMap({}, typeT, dynamicT).code;
});
