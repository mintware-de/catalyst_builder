import 'package:code_builder/code_builder.dart' as cb;

import '../dto/dto.dart';
import 'symbols.dart';

/// Builds the service factory expression.
/// () => MyService()
cb.Expression buildServiceFactory(
    cb.Reference? exposeAsReference,
    cb.Reference serviceType,
    ExtractedService svc) {
  var factory = cb.MethodBuilder();

  factory.returns = cb.refer('void');
  factory.lambda = true;

  var positionalArgs = <cb.Expression>[];
  var namedArgs = <String, cb.Expression>{};

  for (var param in svc.constructorArgs) {
    var defaultValue = '';

    var resolveWithFallbacks =
        tryResolveOrBinding$.call([cb.literal(param.name)]);

    if (param.defaultValue.isNotEmpty) {
      resolveWithFallbacks = resolveWithFallbacks
          .ifNullThen(cb.CodeExpression(cb.Code(param.defaultValue)));
    }

    var val = resolveWithFallbacks;
    if (!param.isOptional && defaultValue.isEmpty) {
      val = resolveOrBinding$.call([cb.literal(param.name)]);
    }
    if (param.isNamed) {
      namedArgs[param.name] = val;
    } else if (param.isPositional) {
      positionalArgs.add(val);
    }
  }
  factory.body = serviceType.call(positionalArgs, namedArgs).code;
  var constructor = factory.build().closure;

  return serviceDescriptorT.call([
    cb.refer('Service', rootPackage).call([], {
      'lifetime': cb.refer(svc.lifetime, rootPackage),
      if (exposeAsReference != null) 'exposeAs': exposeAsReference
    }),
    constructor,
  ]);
}
