import 'package:code_builder/code_builder.dart' as cb;

import '../../../dto/dto.dart';
import '../../service_factory/service_factory.dart';
import '../../symbols.dart';

/// Template for provideKnownServices
cb.Method provideKnownServicesTemplate(List<ExtractedService> services) {
  var serviceFactories = <cb.Reference, cb.Expression>{};

  var pP = cb.refer('p');
  for (var svc in services) {
    var serviceType = cb.refer(svc.service.symbolName, svc.service.library);

    var exposeAs = svc.exposeAs;
    cb.Reference? exposeAsReference;

    if (exposeAs != null) {
      exposeAsReference = cb.refer(exposeAs.symbolName, exposeAs.library);
    }
    serviceFactories[serviceType] = buildServiceFactory(
      exposeAsReference,
      serviceType,
      svc,
      pP,
    );
  }

  return cb.Method((m) {
    m
      ..annotations.add(cb.refer('override'))
      ..name = provideKnownServices$.symbol
      ..returns = mapOfT(typeT, serviceDescriptorT)
      ..requiredParameters.add(cb.Parameter((p) => p
        ..name = pP.symbol!
        ..type = serviceProviderT))
      ..body = cb
          .literalMap(serviceFactories, typeT, serviceDescriptorT)
          .returned
          .statement;
  });
}
