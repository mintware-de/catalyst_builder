import 'package:code_builder/code_builder.dart' as cb;

import '../../helper.dart';
import '../../symbols.dart';

/// Template for register<T>(
///   Service service,
///   T Function(ServiceProvider) factory
/// )
final registerTemplate = cb.Method((m) {
  var typeTP = cb.TypeReference((b) => b..symbol = 'T');

  var serviceP = const cb.Reference('service');
  var factoryP = const cb.Reference('factory');
  var exposeAsP = const cb.Reference('exposeAs');

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
      knownServices$[typeTP.expression]
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
                .assign(typeTP.expression),
          )
          .code
    ]);
});
