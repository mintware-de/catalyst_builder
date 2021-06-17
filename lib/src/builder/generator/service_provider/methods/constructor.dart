import 'package:code_builder/code_builder.dart' as cb;

import '../../../dto/dto.dart';
import '../../service_factory/service_factory.dart';
import '../../symbols.dart';

/// Template for the constructor
cb.Constructor buildProviderConstructor(
  List<ExtractedService> services,
  cb.Reference typeReference,
) {
  return cb.Constructor((ctor) {
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

    ctor
      ..body = cb.Block.of([
        knownServices$.property('addAll').call([
          cb.literalMap(serviceFactories, typeReference, serviceDescriptorT),
        ]).statement,
        exposeMap$.property('addAll').call([
          cb.literalMap(exposeAsData, typeReference, typeReference),
        ]).statement,
      ]);
  });
}
