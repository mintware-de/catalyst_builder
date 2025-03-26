import 'package:catalyst_builder/src/builder/generator/helper.dart';
import 'package:code_builder/code_builder.dart' as cb;

import '../../symbols.dart';

/// Template for resolveByTagTemplate(Symbol tag)
final resolveByTagTemplate = cb.Method((m) {
  var tagP = cb.refer('tag');
  var servicesV = cb.refer('services');
  var svcV = cb.refer('svc');
  m
    ..annotations.add(cb.refer('override'))
    ..name = resolveByTag$.symbol
    ..requiredParameters.addAll([
      cb.Parameter(
        (p) => p
          ..name = tagP.symbol!
          ..type = symbolT,
      )
    ])
    ..body = cb.Block.of([
      initVar(servicesV, cb.literalList([], dynamicT)),
      IfBuilder(servicesByTag$.property('containsKey').call([tagP]).negate())
          .thenReturn(servicesV),
      ForEachBuilder(servicesByTag$[tagP].nullChecked, svcV)
          .finalize(
            servicesV.property('add').call([
              tryResolveInternal$.call([svcV]).asA(dynamicT)
            ]).statement,
          )
          .code,
      servicesV.returned.statement
    ])
    ..returns = listOfT(dynamicT);
});
