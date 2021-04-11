import 'package:code_builder/code_builder.dart' as cb;

import '../dto/dto.dart';
import 'helper.dart';
import 'service_factory.tpl.dart';
import 'symbols.dart';

/// Generates the code for the service provider.
cb.Class buildServiceProviderClass(
  Map<String, dynamic> config,
  List<ExtractedService> services,
) {
  final tryResolveTemplate = cb.Method((m) {
    var typeT = cb.TypeReference((b) => b..symbol = 'T');

    var singletonLifeTime$ = cb.refer('ServiceLifetime.singleton', rootPackage);

    var descriptor$ = cb.refer('descriptor');

    var nullableTypeT = cb.TypeReference((b) => b
      ..symbol = typeT.symbol
      ..isNullable = true);

    var exposedType$ = cb.refer('_exposedType');
    var instance$ = cb.refer('instance');

    m
      ..annotations.add(cb.refer('override'))
      ..name = tryResolve$.symbol
      ..types.add(typeT)
      ..returns = nullableTypeT
      ..body = cb.Block.of([
        initVar(exposedType$, exposeMap$[typeT]),
        fallbackIfNull(exposedType$, typeT).statement,
        IfBuilder(
          serviceInstances$.property('containsKey').call([exposedType$]),
        ).thenReturn(serviceInstances$[exposedType$]),
        initVar(descriptor$, knownServices$[exposedType$]),
        IfBuilder(descriptor$.equalTo(cb.literalNull))
            .thenReturn(cb.literalNull),
        initVar(
          instance$,
          descriptor$.property('produce').call([]),
        ),
        IfBuilder(
          descriptor$
              .property('service')
              .property('lifetime')
              .equalTo(singletonLifeTime$),
        ).then(assign(serviceInstances$[exposedType$], instance$)).code,
        instance$.returned.statement,
      ]);
  });

  final resolveTemplate = cb.Method((m) {
    var typeT = cb.TypeReference((b) => b..symbol = 'T');

    var resolved$ = cb.refer('resolved');

    m
      ..annotations.add(cb.refer('override'))
      ..name = resolve$.symbol
      ..types.add(typeT)
      ..body = cb.Block.of([
        initVar(resolved$, tryResolve$.call([], {}, [typeT])),
        IfBuilder(resolved$.notEqualTo(cb.literalNull)).thenReturn(resolved$),
        cb
            .refer('Exception')
            .call([cb.literal('Service \$${typeT.symbol} not found.')])
            .thrown
            .statement,
      ])
      ..returns = typeT;
  });

  final typeReference = cb.refer('Type');
  final stringReference = cb.refer('String');
  final dynamicReference = cb.refer('dynamic');

  final knownServicesTemplate = cb.Field(
    (f) => f
      ..name = knownServices$.symbol
      ..modifier = cb.FieldModifier.final$
      ..assignment = cb.literalMap({}, typeReference, serviceDescriptorT).code,
  );

  final exposeMapTemplate = cb.Field(
    (f) => f
      ..name = exposeMap$.symbol
      ..modifier = cb.FieldModifier.final$
      ..assignment = cb.literalMap({}, typeReference, typeReference).code,
  );

  final serviceInstancesTemplate = cb.Field(
    (f) => f
      ..name = serviceInstances$.symbol
      ..modifier = cb.FieldModifier.final$
      ..assignment = cb.literalMap({}, typeReference, dynamicReference).code,
  );

  final bindingsTemplate = cb.Field(
    (f) => f
      ..name = bindings$.symbol
      ..modifier = cb.FieldModifier.final$
      ..assignment = cb.literalMap({}, stringReference, dynamicReference).code,
  );

  return cb.Class(
    (c) => c
      ..name = config['providerClassName'] as String
      ..extend = serviceProviderT
      ..fields.addAll([
        knownServicesTemplate,
        exposeMapTemplate,
        serviceInstancesTemplate,
        bindingsTemplate,
      ])
      ..methods.addAll([
        tryResolveTemplate,
        resolveTemplate,
        _tryResolveOrGetBindingTemplate(),
        _resolveOrGetBindingTemplate(),
      ])
      ..constructors.add(
        _buildProviderConstructor(services, typeReference),
      ),
  );
}

cb.Constructor _buildProviderConstructor(
    List<ExtractedService> services, cb.Reference typeReference) {
  var serviceFactories = {};
  var exposeAsData = {};

  for (var svc in services) {
    var serviceType = cb.refer(svc.service.symbolName, svc.service.library);

    var exposeAs = svc.exposeAs;
    cb.Reference? exposeAsReference;

    if (exposeAs != null) {
      exposeAsReference = cb.refer(exposeAs.symbolName, exposeAs.library);
      exposeAsData[exposeAsReference] = serviceType;
    }
    serviceFactories[serviceType] = buildServiceFactory(
      exposeAsReference,
      serviceType,
      svc,
    );
  }

  return cb.Constructor(
    (ctor) => ctor.body = cb.Block.of([
      knownServices$.property('addAll').call([
        cb.literalMap(serviceFactories, typeReference, serviceDescriptorT),
      ]).statement,
      exposeMap$.property('addAll').call([
        cb.literalMap(exposeAsData, typeReference, typeReference),
      ]).statement
    ]),
  );
}

cb.Method _resolveOrGetBindingTemplate() {
  var typeT = cb.TypeReference((b) => b..symbol = 'T');

  var paramB$ = cb.refer('b');
  var body = bindings$.property('containsKey').call([paramB$]).conditional(
    tryResolveOrBinding$.call([paramB$], {}, [typeT]),
    resolve$.call([], {}, [typeT]),
  );

  return cb.Method(
    (m) => m
      ..name = resolveOrBinding$.symbol
      ..lambda = true
      ..requiredParameters.addAll([
        cb.Parameter(
          (p) => p
            ..name = paramB$.symbol
            ..type = cb.refer('String'),
        ),
      ])
      ..body = body.code
      ..types.add(typeT)
      ..returns = typeT,
  );
}

cb.Method _tryResolveOrGetBindingTemplate() {
  var typeT = cb.TypeReference((b) => b..symbol = 'T');

  var paramB$ = cb.refer('b');
  var body = tryResolve$
      .call([], {}, [typeT]).ifNullThen(bindings$[paramB$].asA(typeT));

  return cb.Method(
    (m) => m
      ..name = tryResolveOrBinding$.symbol
      ..requiredParameters.addAll([
        cb.Parameter(
          (p) => p
            ..name = paramB$.symbol
            ..type = cb.refer('String'),
        ),
      ])
      ..body = body.code
      ..types.add(typeT)
      ..returns = typeT,
  );
}
