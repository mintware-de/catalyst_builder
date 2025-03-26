import 'package:code_builder/code_builder.dart' as cb;

import '../../helper.dart';
import '../../symbols.dart';

/// Template for ServiceProvider enhance({
///   List&lt;ServiceDescriptor&gt; services = const [],
///   Map&lt;String, dynamic&gt; parameters = const {},
/// });
cb.Method enhanceTemplate(String providerClassName) {
  return cb.Method((m) {
    var servicesP = const cb.Reference('services');
    var parametersP = const cb.Reference('parameters');

    var serviceV = const cb.Reference('service');
    var enhancedV = const cb.Reference('enhanced');
    var pluginV = const cb.Reference('plugin');

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
        ForEachBuilder(appliedPlugins$, pluginV)
            .finalize(enhancedV
                .property(applyPlugin$.symbol!)
                .call([pluginV]).statement)
            .code,
        enhancedV
            .property(serviceInstances$.symbol!)
            .assign(serviceInstances$)
            .statement,
        _addKnownServices(enhancedV),
        enhancedV
            .property(exposeMap$.symbol!)
            .property('addAll')
            .call([exposeMap$]).statement,
        ForEachBuilder(servicesP, serviceV)
            .finalize(enhancedV.property(registerInternal$.symbol!).call([
              serviceV.property('returnType'),
              serviceV.property('factory'),
              serviceV.property('service'),
            ]).statement)
            .code,
        enhancedV
            .property(parameters$.symbol!)
            .property('addAll')
            .call([this$.property(parameters$.symbol!)]).statement,
        enhancedV
            .property(parameters$.symbol!)
            .property('addAll')
            .call([parameters$]).statement,
        enhancedV.property(booted$.symbol!).assign(cb.literalTrue).statement,
        enhancedV.returned.statement,
      ]);
  });
}

/// Adds missing _knownServices to the enhanced provider _knownServices map.
cb.Code _addKnownServices(cb.Reference enhancedV) {
  var elV = const cb.Reference('el');

  return enhancedV.property(knownServices$.symbol!).property('addAll').call([
    cb.refer('Map').property('fromEntries').call([
      knownServices$.property('entries').property('where').call([
        (cb.MethodBuilder()
              ..lambda = true
              ..requiredParameters.addAll([
                cb.Parameter((b) => b..name = elV.symbol!),
              ])
              ..body = enhancedV
                  .negate()
                  .property(knownServices$.symbol!)
                  .property('containsKey')
                  .call([elV.property('key')]).code)
            .build()
            .closure
      ])
    ])
  ]).statement;
}
