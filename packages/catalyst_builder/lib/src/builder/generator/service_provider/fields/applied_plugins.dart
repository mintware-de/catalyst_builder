import 'package:code_builder/code_builder.dart' as cb;

import '../../symbols.dart';

/// Template for _appliedPlugins
final appliedPluginsTemplate = cb.Field((f) {
  f
    ..name = appliedPlugins$.symbol
    ..modifier = cb.FieldModifier.final$
    ..assignment = cb.literalList([], serviceProviderPluginT).code;
});
