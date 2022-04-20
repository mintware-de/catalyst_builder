import 'package:code_builder/code_builder.dart' as cb;

import '../../helper.dart';
import '../../symbols.dart';

/// Template for ServiceProvider enhance({
///   List<ServiceDescriptor> services = const [],
///   Map<String, dynamic> parameters = const {},
/// });
cb.Method enhanceTemplate(String providerClassName) {
  return cb.Method((m) {
    var servicesP = const cb.Reference('services');
    var parametersP = const cb.Reference('parameters');

    var serviceV = const cb.Reference('service');
    var enhancedV = const cb.Reference('enhanced');

    m
      ..annotations.add(cb.refer('override'))
      ..name = enhance$.symbol
      ..returns = serviceProviderT
      ..optionalParameters.addAll([
        cb.Parameter(
          (p) => p
            ..name = servicesP.symbol!
            ..named = true
            ..type = ((cb.TypeReferenceBuilder()
                  ..symbol = 'List'
                  ..types.add(lazyServiceDescriptorT))
                .build())
            ..defaultTo = cb.literalConstList([], lazyServiceDescriptorT).code,
        ),
        cb.Parameter(
          (p) => p
            ..name = parametersP.symbol!
            ..named = true
            ..type = ((cb.TypeReferenceBuilder()
                  ..symbol = 'Map'
                  ..types.addAll([stringT, dynamicT]))
                .build())
            ..defaultTo = cb.literalConstMap({}, stringT, dynamicT).code,
        ),
      ])
      ..body = cb.Block.of([
        ensureBoot$.call([]).statement,
        initVar(enhancedV, cb.refer(providerClassName).newInstance([])),
        enhancedV
            .property(serviceInstances$.symbol!)
            .property('addAll')
            .call([serviceInstances$]).statement,
        ForEachBuilder(servicesP, serviceV)
            .finalize(enhancedV.property(register$.symbol!).call([
              serviceV.property('factory'),
              serviceV.property('service'),
            ]))
            .code,
        enhancedV
            .property(parameters$.symbol!)
            .property('addAll')
            .call([parameters$]).statement,
        enhancedV.property(booted$.symbol!).assign(cb.literalTrue).statement,
        enhancedV.returned.statement,
      ]);
  });
}
