import 'package:code_builder/code_builder.dart' as cb;

import '../../helper.dart';
import '../../symbols.dart';

/// Template for resolve<T>()
final resolveTemplate = cb.Method((m) {
  var typeT = cb.TypeReference((b) => b..symbol = 'T');

  var resolved$ = cb.refer('resolved');

  m
    ..annotations.add(cb.refer('override'))
    ..name = resolve$.symbol
    ..types.add(typeT)
    ..body = cb.Block.of([
      ensureBoot$.call([]).statement,
      initVar(resolved$, tryResolve$.call([], {}, [typeT])),
      IfBuilder(resolved$.notEqualTo(cb.literalNull)).thenReturn(resolved$),
      serviceNotFoundExceptionT.call([typeT]).thrown.statement,
    ])
    ..returns = typeT;
});
