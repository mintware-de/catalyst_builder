import 'package:code_builder/code_builder.dart' as cb;

import '../../dto/dto.dart';
import '../symbols.dart';
import 'fields/fields.dart';
import 'methods/methods.dart';

/// Generates the code for the service provider.
cb.Class buildServiceProviderClass(
  String providerClassName,
  String pluginClassName,
  List<ExtractedService> services,
) {
  return cb.Class((c) => c
    ..name = providerClassName
    ..extend = serviceProviderT
    ..implements.addAll([
      serviceRegistryT,
    ])
    ..fields.addAll([
      bootedTemplate,
      knownServicesTemplate,
      exposeMapTemplate,
      serviceInstancesTemplate,
      servicesByTagTemplate,
      preloadedTypesTemplate,
      appliedPluginsTemplate,
    ])
    ..methods.addAll([
      tryResolveTemplate,
      tryResolveInternalTemplate,
      resolveTemplate,
      resolveByTagTemplate,
      tryResolveOrGetParameterTemplate,
      resolveOrGetParameterTemplate,
      bootTemplate(services),
      ensureBootedTemplate,
      hasTemplate,
      registerTemplate,
      registerInternalTemplate,
      enhanceTemplate(providerClassName),
      applyPlugin(),
    ])
    ..constructors.add(
      buildProviderConstructor(pluginClassName),
    ));
}
