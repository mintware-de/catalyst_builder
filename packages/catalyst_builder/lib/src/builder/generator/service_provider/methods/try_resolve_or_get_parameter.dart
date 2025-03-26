import 'package:code_builder/code_builder.dart' as cb;

import '../../helper.dart';
import '../../symbols.dart';

/// Template for _tryResolveOrGetParameter()
final tryResolveOrGetParameterTemplate = cb.Method((m) {
  var typeT = cb.TypeReference((b) => b..symbol = 'T');
  var nullableTypeT = cb.TypeReference((b) => b
    ..symbol = typeT.symbol
    ..isNullable = true);

  var paramB$ = cb.refer('b');
  var resolvedService$ = cb.refer('resolvedService');

  var body = cb.Block.of([
    initVar(resolvedService$, tryResolve$.call([], {}, [typeT])),
    IfBuilder(resolvedService$.notEqualTo(cb.literalNull))
        .thenReturn(resolvedService$),
    IfBuilder(parameters$[paramB$].isA(typeT))
        .thenReturn(parameters$[paramB$].asA(typeT)),
    cb.literalNull.returned.statement,
  ]);

  m
    ..name = tryResolveOrGetParameter$.symbol
    ..annotations.add(cb.refer('override'))
    ..requiredParameters.addAll([
      cb.Parameter((p) => p
        ..name = paramB$.symbol!
        ..type = stringT)
    ])
    ..body = body
    ..types.add(typeT)
    ..returns = nullableTypeT;
});
