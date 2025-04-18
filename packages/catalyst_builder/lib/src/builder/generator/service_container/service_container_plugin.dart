import 'package:code_builder/code_builder.dart' as cb;

import '../../dto/dto.dart';
import '../symbols.dart';
import 'methods/methods.dart';

/// Generates the code for the service container.
cb.Class buildServiceContainerPluginClass(
  String pluginClassName,
  List<ExtractedService> services,
) {
  return cb.Class((c) => c
    ..name = pluginClassName
    ..implements.addAll([serviceContainerPluginT])
    ..methods.addAll([
      provideKnownServicesTemplate(services),
      provideExposesTemplate(services),
      providePreloadedTypesTemplate(services),
      provideServiceTagsTemplate(services),
    ]));
}

cb.Extension buildExtension(String pluginClassName) {
  return cb.Extension((e) => e
    ..name = "${pluginClassName}Extension"
    ..on = abstractServiceContainerT
    ..methods.add(cb.Method((m) => m
      ..name = "use$pluginClassName"
      ..returns = voidT
      ..body = cb.Block.of([
        applyPlugin$.call([cb.refer(pluginClassName).call([])]).statement
      ]))));
}
