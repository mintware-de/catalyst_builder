import 'package:code_builder/code_builder.dart' as cb;

import '../../helper.dart';
import '../../symbols.dart';

/// Template for _resolveOrGetParameter()
final resolveOrGetParameterTemplate = cb.Method((m) {
  var typeT = cb.TypeReference((b) => b..symbol = 'T');

  var paramParamName$ = cb.refer('param');
  var paramBoundParameter = cb.refer('parameter');
  var paramRequiredBy$ = cb.refer('requiredBy');

  var resolved$ = cb.refer('resolved');
  var body = cb.Block.of([
    initVar(
        resolved$,
        tryResolveOrGetParameter$.call(
          [paramBoundParameter.ifNullThen(paramParamName$)],
          {},
          [typeT],
        )),
    IfBuilder(resolved$.equalTo(cb.literalNull))
        .then(dependencyNotFoundExceptionT.call([
          paramRequiredBy$,
          paramParamName$,
          serviceNotFoundExceptionT.call([typeT])
        ]).thrown)
        .code,
    resolved$.returned.statement,
  ]);

  m
    ..name = resolveOrGetParameter$.symbol
    ..requiredParameters.addAll([
      cb.Parameter((p) => p
        ..name = paramRequiredBy$.symbol!
        ..required = false
        ..type = cb.refer('Type')),
      cb.Parameter((p) => p
        ..name = paramParamName$.symbol!
        ..type = cb.refer('String')),
    ])
    ..optionalParameters.addAll([
      cb.Parameter((p) => p
        ..name = paramBoundParameter.symbol!
        ..required = false
        ..type = cb.refer('String?')),
    ])
    ..body = body
    ..types.add(typeT)
    ..returns = typeT;
});
