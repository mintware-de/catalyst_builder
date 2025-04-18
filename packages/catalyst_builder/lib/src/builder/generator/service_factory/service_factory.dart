import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:code_builder/code_builder.dart' as cb;

import '../../dto/dto.dart';
import '../symbols.dart';

/// Builds the service factory expression.
/// () => MyService()
cb.Expression buildServiceFactory(
  cb.Reference? exposeAsReference,
  cb.Reference serviceType,
  ExtractedService svc,
  cb.Reference containerP,
) {
  var factory = cb.MethodBuilder();

  factory.returns = serviceType;
  factory.lambda = true;

  var positionalArgs = <cb.Expression>[];
  var namedArgs = <String, cb.Expression>{};

  var tryResolveOrGetParameter_ =
      containerP.property(tryResolveOrGetParameter$.symbol!);
  var resolveByTag_ = containerP.property(resolveByTag$.symbol!);
  var resolveOrGetParameter_ =
      containerP.property(resolveOrGetParameter$.symbol!);

  for (var param in svc.constructorArgs) {
    var defaultValue = '';
    var parameterName = param.inject?.parameter ?? param.name;

    var resolveWithFallbacks =
        tryResolveOrGetParameter_.call([cb.literal(parameterName)]);

    if (param.defaultValue.isNotEmpty) {
      resolveWithFallbacks = resolveWithFallbacks
          .ifNullThen(cb.CodeExpression(cb.Code(param.defaultValue)));
    }

    var val = resolveWithFallbacks;
    var tag = param.inject?.tag;
    if (tag != null) {
      val = resolveByTag_.call([cb.refer('#$tag')]).property('cast').call([]);
    } else if (!param.isOptional && defaultValue.isEmpty) {
      val = resolveOrGetParameter_.call([
        serviceType,
        cb.literal(param.name),
        if (parameterName != param.name) cb.literal(parameterName),
      ]);
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
    serviceT.constInstance([], {
      if (svc.lifetime != ServiceLifetime.singleton.toString())
        'lifetime': cb.refer(svc.lifetime, contractsPackage),
      if (exposeAsReference != null) 'exposeAs': exposeAsReference
    }),
    constructor,
  ]);
}
