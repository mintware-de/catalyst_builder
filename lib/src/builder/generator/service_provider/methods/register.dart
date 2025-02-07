import 'package:code_builder/code_builder.dart' as cb;

import '../../symbols.dart';

/// Template for register&lt;T&gt;(
///   Service service,
///   T Function(ServiceProvider) factory
/// )
final registerTemplate = cb.Method((m) {
  var typeTP = cb.TypeReference((b) => b..symbol = 'T');

  var serviceP = const cb.Reference('service');
  var factoryP = const cb.Reference('factory');

  m
    ..annotations.add(cb.refer('override'))
    ..name = register$.symbol
    ..types.add(typeTP)
    ..returns = voidT
    ..requiredParameters.addAll([
      cb.Parameter(
        (p) => p
          ..name = factoryP.symbol!
          ..type = cb.FunctionType((b) => b
            ..returnType = typeTP
            ..requiredParameters.addAll([
              serviceProviderT,
            ]))
          ..required = false,
      )
    ])
    ..optionalParameters.addAll([
      cb.Parameter(
        (p) => p
          ..name = serviceP.symbol!
          ..type = serviceT
          ..defaultTo = serviceT.constInstance([]).code,
      ),
    ])
    ..body = cb.Block.of([
      registerInternal$.call([typeTP, factoryP, serviceP]).statement,
    ]);
});
