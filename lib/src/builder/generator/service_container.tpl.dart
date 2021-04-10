import 'package:code_builder/code_builder.dart' as cb;
import 'package:di_experimental/src/builder/preflight_storage.dart';

final rootPackage = 'package:di_experimental/di_experimental.dart';
final tryResolve = cb.Reference('tryResolve');
final resolve = cb.Reference('resolve');
final knownServices = cb.Reference('_knownServices');
final exposeMap = cb.Reference('_exposeMap');
final serviceInstances = cb.Reference('_serviceInstances');
final bindings = cb.Reference('bindings');
final tServiceDescriptor = cb.refer('ServiceDescriptor', rootPackage);
final tServiceProvider = cb.refer('ServiceProvider', rootPackage);

cb.Class buildServiceContainerTemplate(
  cb.DartEmitter emitter,
  PreflightStorage storage,
) {
  final tryResolveTemplate = cb.Method((m) {
    var typeT = cb.TypeReference((b) => b..symbol = 'T');

    var lifetimeReference = cb.refer(
      'ServiceLifetime.singleton',
      rootPackage,
    );

    var descriptorLifetimeCompare =
        cb.CodeExpression(cb.Code('descriptor.service.lifetime'))
            .equalTo(lifetimeReference);

    var nullableTypeT = cb.TypeReference((b) => b
      ..symbol = typeT.symbol
      ..isNullable = true);
    m
      ..annotations.add(cb.CodeExpression(cb.Code('override')))
      ..name = tryResolve.symbol
      ..types.add(typeT)
      ..returns = nullableTypeT
      ..body = cb.Code('''
var _exposedType = ${exposeMap.symbol}[T];
_exposedType ??= T;

if (${serviceInstances.symbol}.containsKey(_exposedType)) {
  return ${serviceInstances.symbol}[_exposedType];
}
var descriptor = ${knownServices.symbol}[_exposedType];
if (descriptor != null) {
  var instance = descriptor.produce(this);

  if (${descriptorLifetimeCompare.accept(emitter)}) {
    ${serviceInstances.symbol}[_exposedType] = instance;
  }
  return instance;
}
return null;
''');
  });

  final resolveTemplate = cb.Method((m) {
    var typeT = cb.TypeReference((b) => b..symbol = 'T');
    m
      ..annotations.add(cb.CodeExpression(cb.Code('override')))
      ..name = resolve.symbol
      ..types.add(typeT)
      ..body = cb.Code('''
var resolved = ${tryResolve.symbol}<${typeT.symbol}>();
if (resolved != null) {
  return resolved;
}

throw Exception('Service \$${typeT.symbol} not found.');
''')
      ..returns = typeT;
  });

  final typeReference = cb.refer('Type');
  final stringReference = cb.refer('String');
  final dynamicReference = cb.refer('dynamic');

  var knownServicesData = {};
  var exposeAsData = {};

  for (var svc in storage.services) {
    var lifetimeIndex = svc.service
            .computeConstantValue()
            ?.getField('lifetime')
            ?.getField('index')
            ?.toIntValue() ??
        1;

    var exposeAs = svc.service
        .computeConstantValue()
        ?.getField('exposeAs')
        ?.toTypeValue()
        ?.element;

    var lifetime =
        cb.refer('ServiceLifetime.values[$lifetimeIndex]', rootPackage);

    var serviceType =
        cb.refer(svc.element.name, svc.element.librarySource.uri.toString());

    var constructor = _buildConstructor(serviceType, emitter, svc);

    var exposeAsReference;
    if (exposeAs != null) {
      exposeAsReference = cb.refer(
        exposeAs.name,
        exposeAs.librarySource?.uri.toString(),
      );
      exposeAsData[exposeAsReference] = serviceType;
    }

    knownServicesData[serviceType] = tServiceDescriptor.call([
      cb.refer('Service', rootPackage).call([], {
        if (lifetimeIndex != 1) 'lifetime': lifetime,
        if (exposeAsReference != null) 'exposeAs': exposeAsReference
      }),
      constructor,
    ]);
  }

  final knownServicesTemplate = cb.Field(
    (f) => f
      ..name = knownServices.symbol
      ..modifier = cb.FieldModifier.final$
      ..assignment = cb.literalMap({}, typeReference, tServiceDescriptor).code,
  );

  final exposeMapTemplate = cb.Field(
    (f) => f
      ..name = exposeMap.symbol
      ..modifier = cb.FieldModifier.final$
      ..assignment =
          cb.literalMap(exposeAsData, typeReference, typeReference).code,
  );

  final serviceInstancesTemplate = cb.Field(
    (f) => f
      ..name = serviceInstances.symbol
      ..modifier = cb.FieldModifier.final$
      ..assignment = cb.literalMap({}, typeReference, dynamicReference).code,
  );

  final bindingsTemplate = cb.Field(
    (f) => f
      ..name = bindings.symbol
      ..modifier = cb.FieldModifier.final$
      ..assignment = cb.literalMap({}, stringReference, dynamicReference).code,
  );

  return cb.Class(
    (c) => c
      ..name = 'DefaultServiceProvider'
      ..extend = tServiceProvider
      ..fields.addAll([
        knownServicesTemplate,
        exposeMapTemplate,
        serviceInstancesTemplate,
        bindingsTemplate,
      ])
      ..methods.addAll([
        tryResolveTemplate,
        resolveTemplate,
      ])
      ..constructors.add(
        cb.Constructor(
          (ctor) => ctor.body = cb.Code(
              '${knownServices.symbol}.addAll(${cb.literalMap(knownServicesData, typeReference, tServiceDescriptor).accept(emitter)});'),
        ),
      ),
  );
}

cb.Expression _buildConstructor(
  cb.Reference serviceType,
  cb.DartEmitter emitter,
  ServiceElementPair svc,
) {
  var factory = cb.MethodBuilder();
  var provider = cb.Parameter((p) => p.name = 'p');

  factory.requiredParameters.add(provider);
  factory.returns = cb.refer('void');

  var positionalArgs = <cb.Expression>[];
  var namedArgs = <String, cb.Expression>{};

  for (var ctor in svc.element.constructors) {
    if (ctor.isFactory || ctor.name != '') {
      continue;
    }

    for (var param in ctor.parameters) {
      var defaultValue = '';

      if (param.hasDefaultValue) {
        defaultValue = ' ?? ${param.defaultValueCode}';
      }

      var resolveWithFallbacks =
          'p.tryResolve() $defaultValue ?? ${bindings.symbol}[\'${param.name}\']';
      var val = param.isOptional || defaultValue.isNotEmpty
          ? cb.CodeExpression(cb.Code(resolveWithFallbacks))
          : cb.CodeExpression(cb.Code(
              '${bindings.symbol}.containsKey(\'${param.name}\') ? ($resolveWithFallbacks) : p.resolve()'));
      if (param.isNamed) {
        namedArgs[param.name] = val;
      } else if (param.isPositional) {
        positionalArgs.add(val);
      }
    }
    break;
  }

  factory.body = cb.Code(
      'return ${serviceType.call(positionalArgs, namedArgs).accept(emitter)};');
  var constructor = factory.build().closure;
  return constructor;
}
