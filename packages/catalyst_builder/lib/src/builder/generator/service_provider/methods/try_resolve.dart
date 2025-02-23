import 'package:code_builder/code_builder.dart' as cb;

import '../../symbols.dart';

/// Template for tryResolve&lt;T&gt;()
final tryResolveTemplate = cb.Method((m) {
  var typeT = cb.TypeReference((b) => b..symbol = 'T');

  var nullableTypeT = cb.TypeReference((b) => b
    ..symbol = typeT.symbol
    ..isNullable = true);

  m
    ..annotations.add(cb.refer('override'))
    ..name = tryResolve$.symbol
    ..types.add(typeT)
    ..returns = nullableTypeT
    ..body = cb.Block.of([
      tryResolveInternal$.call([typeT], {}, [typeT]).returned.statement,
    ]);
});
