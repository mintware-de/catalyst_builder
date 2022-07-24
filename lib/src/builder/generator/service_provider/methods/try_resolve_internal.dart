import 'package:code_builder/code_builder.dart' as cb;

import '../../helper.dart';
import '../../symbols.dart';

/// Template for _tryResolveInternal<T>(Type t)
final tryResolveInternalTemplate = cb.Method((m) {
  var typeT = cb.TypeReference((b) => b..symbol = 'T');

  var singletonLifeTime$ = cb.refer('ServiceLifetime.singleton', rootPackage);

  var descriptor$ = cb.refer('descriptor');

  var nullableTypeT = cb.TypeReference((b) => b
    ..symbol = typeT.symbol
    ..isNullable = true);

  var exposedType$ = cb.refer('exposedType');
  var instance$ = cb.refer('instance');

  var typeP = cb.refer('t');

  m
    ..name = tryResolveInternal$.symbol
    ..types.add(typeT)
    ..requiredParameters.add(cb.Parameter(
      (p) => p
        ..name = typeP.symbol!
        ..type = cb.refer('Type'),
    ))
    ..returns = nullableTypeT
    ..body = cb.Block.of([
      ensureBoot$.call([]).statement,
      initVar(exposedType$, exposeMap$[typeP]),
      fallbackIfNull(exposedType$, typeP).statement,
      IfBuilder(
        serviceInstances$.property('containsKey').call([exposedType$]),
      ).thenReturn(serviceInstances$[exposedType$]),
      initVar(descriptor$, knownServices$[exposedType$]),
      IfBuilder(descriptor$.equalTo(cb.literalNull)).thenReturn(cb.literalNull),
      initVar(instance$, descriptor$.property('produce').call([])),
      IfBuilder(descriptor$
              .property('service')
              .property('lifetime')
              .equalTo(singletonLifeTime$))
          .then(assign(serviceInstances$[exposedType$], instance$))
          .code,
      instance$.returned.statement,
    ]);
});
