import 'package:code_builder/code_builder.dart' as cb;

import '../../helper.dart';
import '../../symbols.dart';

/// Template for has<T>([Type t = null])
final hasTemplate = cb.Method((m) {
  var typeTP = cb.TypeReference((b) => b..symbol = 'T');

  var typeP = cb.Reference('type');

  /// var lookupType = type ?? T;
  /// return _knownServices.containsKey(_exposeMap[lookupType] ?? lookupType);

  var lookupType$ = cb.refer('lookupType');

  m
    ..annotations.add(cb.refer('override'))
    ..name = has$.symbol
    ..types.add(typeTP)
    ..returns = boolT
    ..optionalParameters.addAll([
      cb.Parameter(
        (p) => p
          ..name = typeP.symbol!
          ..type = nullable(typeT)
          ..required = false,
      )
    ])
    ..body = cb.Block.of([
      initVar(lookupType$, typeP.ifNullThen(typeTP)),
      knownServices$
          .property('containsKey')
          .call([exposeMap$[lookupType$].ifNullThen(lookupType$)])
          .returned
          .statement,
    ]);
});
