import 'package:code_builder/code_builder.dart' as cb;

import '../../helper.dart';
import '../../symbols.dart';

/// Template for boot()
cb.Method applyPlugin() {
  return cb.Method((m) {
    final pluginP = cb.refer('plugin');
    var entryV = const cb.Reference('entry');
    var typeV = const cb.Reference('type');

    m
      ..name = applyPlugin$.symbol
      ..returns = voidT
      ..requiredParameters.addAll([
        cb.Parameter((p) => p
          ..name = pluginP.symbol!
          ..type = serviceProviderPluginT)
      ])
      ..annotations.add(cb.refer('override'))
      ..body = cb.Block.of([
        // Guard
        IfBuilder(booted$)
            .then(providerAlreadyBootedExceptionT.constInstance([]).thrown)
            .code,
        // Add _knownServices
        knownServices$.property('addAll').call([
          pluginP.property(provideKnownServices$.symbol!).call([])
        ]).statement,
        // add _exposeMap
        exposeMap$.property('addAll').call(
            [pluginP.property(provideExposes$.symbol!).call([])]).statement,
        preloadedTypes$.property('addAll').call([
          pluginP.property(providePreloadedTypes$.symbol!).call([])
        ]).statement,

        // Add tagged services
        ForEachBuilder(
                pluginP
                    .property(provideServiceTags$.symbol!)
                    .call([]).property('entries'),
                entryV)
            .finalize(cb.CodeExpression(cb.Block.of([
              IfBuilder(servicesByTag$
                      .property('containsKey')
                      .call([entryV.property('key')]).negate())
                  .then(servicesByTag$
                      .index(entryV.property('key'))
                      .assign(cb.literalList([], typeT)))
                  .code,
              ForEachBuilder(entryV.property('value'), typeV)
                  .finalize(IfBuilder(servicesByTag$
                          .negate()
                          .index(entryV.property('key'))
                          .nullChecked
                          .property('contains')
                          .call([typeV]))
                      .then(servicesByTag$
                          .index(entryV.property('key '))
                          .nullChecked
                          .property('add')
                          .call([typeV]))
                      .code)
                  .code
            ])).code)
            .code
      ]);
  });
}
