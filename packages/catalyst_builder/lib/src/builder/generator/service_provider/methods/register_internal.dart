import 'package:code_builder/code_builder.dart' as cb;

import '../../helper.dart';
import '../../symbols.dart';

/// Template for _registerInternal&lt;T&gt;(
///   Type tReal,
///   Service service,
///   T Function(ServiceProvider) factory
/// )
final registerInternalTemplate = cb.Method((m) {
  var typeTP = cb.TypeReference((b) => b..symbol = 'T');

  var tRealP = const cb.Reference('tReal');
  var serviceP = const cb.Reference('service');
  var factoryP = const cb.Reference('factory');
  var exposeAsP = const cb.Reference('exposeAs');

  m
    ..name = registerInternal$.symbol
    ..types.add(typeTP)
    ..returns = voidT
    ..requiredParameters.addAll([
      cb.Parameter(
        (p) => p
          ..name = tRealP.symbol!
          ..type = typeT
          ..required = false,
      ),
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
      knownServices$[tRealP]
          .assign(serviceDescriptorT.call([
            serviceP,
            cb.Method(
              (mb) => mb
                ..lambda = true
                ..body = factoryP.call([this$]).code,
            ).closure,
          ]))
          .statement,
      IfBuilder(serviceP.property(exposeAsP.symbol!).notEqualTo(cb.literalNull))
          .then(
            exposeMap$[serviceP.property(exposeAsP.symbol!).nullChecked]
                .assign(tRealP.expression),
          )
          .code
    ]);
});
