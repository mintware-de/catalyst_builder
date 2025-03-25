import 'package:code_builder/code_builder.dart' as cb;

import '../../dto/dto.dart';
import '../symbols.dart';
import 'fields/fields.dart';
import 'methods/methods.dart';

/// Generates the code for the service provider.
cb.Class buildServiceProviderClass(
  String providerClassName,
  List<ExtractedService> services,
) {
  return cb.Class((c) => c
    ..name = providerClassName
    ..extend = serviceProviderT
    ..implements.addAll([serviceRegistryT, enhanceableProviderT])
    ..fields.addAll([
      bootedTemplate,
      knownServicesTemplate,
      exposeMapTemplate,
      serviceInstancesTemplate,
      servicesByTagTemplate,
      preloadedTypesTemplate,
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
    ])
    ..constructors.add(
      buildProviderConstructor(services, typeT),
    ));
}
