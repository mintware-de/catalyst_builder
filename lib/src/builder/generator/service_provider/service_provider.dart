import 'package:code_builder/code_builder.dart' as cb;

import '../../dto/dto.dart';
import '../symbols.dart';
import 'fields/fields.dart';
import 'methods/methods.dart';

/// Generates the code for the service provider.
cb.Class buildServiceProviderClass(
  Map<String, dynamic> config,
  List<ExtractedService> services,
) {
  return cb.Class((c) => c
    ..name = config['providerClassName'] as String
    ..extend = serviceProviderT
    ..implements.addAll([serviceRegistryT, enhanceableProviderT])
    ..fields.addAll([
      bootedTemplate,
      knownServicesTemplate,
      exposeMapTemplate,
      serviceInstancesTemplate,
      servicesByTagTemplate,
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
      enhanceTemplate(config['providerClassName'].toString()),
    ])
    ..constructors.add(
      buildProviderConstructor(services, typeT),
    ));
}
