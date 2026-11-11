import 'package:build/build.dart';
import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';
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
  // The factory lambda receives the container that resolves the service.
  // The type is inferred from the ServiceDescriptor's factory parameter.
  factory.requiredParameters
      .add(cb.Parameter((p) => p..name = containerP.symbol!));

  var positionalArgs = <cb.Expression>[];
  var namedArgs = <String, cb.Expression>{};

  var tryResolveOrGetParameter_ =
      containerP.property(tryResolveOrGetParameter$.symbol!);
  var resolveByTag_ = containerP.property(resolveByTag$.symbol!);
  var resolveOrGetParameter_ =
      containerP.property(resolveOrGetParameter$.symbol!);

  for (var param in svc.constructorArgs) {
    var parameterName = param.inject?.parameter ?? param.name;

    // The type argument is emitted explicitly and non-nullable whenever
    // the parameter type could be resolved. `null` is handled by the
    // chosen resolve method, not by the type argument.
    var typeArgument = _buildTypeArgument(param);

    var resolveWithFallbacks = tryResolveOrGetParameter_.call(
      [cb.literal(parameterName)],
      {},
      [if (typeArgument != null) typeArgument],
    );

    if (param.defaultValue.isNotEmpty) {
      resolveWithFallbacks = resolveWithFallbacks
          .ifNullThen(cb.CodeExpression(cb.Code(param.defaultValue)));
    }

    var val = resolveWithFallbacks;
    var tag = param.inject?.tag;
    if (tag != null) {
      val = resolveByTag_.call([cb.refer('#$tag')]).property('cast').call([]);
    } else if (!param.isOptional && param.isNullable) {
      // A required parameter with a nullable type: `null` is a valid
      // value, so never fail here.
      val = resolveWithFallbacks;
    } else if (!param.isOptional) {
      if (param.type == null) {
        log.warning(
          'Could not resolve the type of parameter '
          "'${param.name}' of ${svc.service.symbolName}. "
          'Falling back to type inference.',
        );
      }
      val = resolveOrGetParameter_.call(
        [
          serviceType,
          cb.literal(param.name),
          if (parameterName != param.name) cb.literal(parameterName),
        ],
        {},
        [if (typeArgument != null) typeArgument],
      );
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
        'lifetime': cb.refer(svc.lifetime, runtimePackage),
      if (exposeAsReference != null) 'exposeAs': exposeAsReference
    }),
    constructor,
  ]);
}

/// Builds the explicit type argument to emit for [param], or `null` if the
/// parameter type could not be resolved.
///
/// The top level is always emitted non-nullable: nullable parameters are
/// resolved through methods that may return `null`, so the nullability does
/// not belong into the type argument.
cb.TypeReference? _buildTypeArgument(ConstructorArg param) {
  var typeRef = param.type;
  if (typeRef == null) {
    return null;
  }
  return (cb.TypeReferenceBuilder()
        ..symbol = typeRef.symbolName
        ..url = typeRef.library
        ..isNullable = false
        ..types.addAll(
          typeRef.typeArguments.map(_buildTypeArgumentFromRef).nonNulls,
        ))
      .build();
}

cb.TypeReference? _buildTypeArgumentFromRef(TypeRef typeRef) {
  return (cb.TypeReferenceBuilder()
        ..symbol = typeRef.symbolName
        ..url = typeRef.library
        ..isNullable = typeRef.isNullable
        ..types.addAll(
          typeRef.typeArguments.map(_buildTypeArgumentFromRef).nonNulls,
        ))
      .build();
}
