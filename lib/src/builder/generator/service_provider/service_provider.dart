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
    ..fields.addAll([
      bootedTemplate,
      knownServicesTemplate,
      exposeMapTemplate,
      serviceInstancesTemplate,
      parametersTemplate,
    ])
    ..methods.addAll([
      tryResolveTemplate,
      resolveTemplate,
      tryResolveOrGetParameterTemplate,
      resolveOrGetParameterTemplate,
      bootTemplate(services),
      ensureBootedTemplate,
      hasTemplate,
    ])
    ..constructors.add(
      buildProviderConstructor(services, typeT),
    ));
}
