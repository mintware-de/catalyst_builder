import 'package:code_builder/code_builder.dart' as cb;

import '../../helper.dart';
import '../../symbols.dart';

/// Template for tryResolve<T>()
final tryResolveTemplate = cb.Method((m) {
  var typeT = cb.TypeReference((b) => b..symbol = 'T');

  var singletonLifeTime$ = cb.refer('ServiceLifetime.singleton', rootPackage);

  var descriptor$ = cb.refer('descriptor');

  var nullableTypeT = cb.TypeReference((b) => b
    ..symbol = typeT.symbol
    ..isNullable = true);

  var exposedType$ = cb.refer('_exposedType');
  var instance$ = cb.refer('instance');

  m
    ..annotations.add(cb.refer('override'))
    ..name = tryResolve$.symbol
    ..types.add(typeT)
    ..returns = nullableTypeT
    ..body = cb.Block.of([
      ensureBoot$.call([]).statement,
      initVar(exposedType$, exposeMap$[typeT]),
      fallbackIfNull(exposedType$, typeT).statement,
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
