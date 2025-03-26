import 'package:code_builder/code_builder.dart' as cb;

import '../../../dto/dto.dart';
import '../../symbols.dart';

/// Template for providePreloadedTypes
cb.Method providePreloadedTypesTemplate(List<ExtractedService> services) {
  var preloadServices = <cb.Reference>[];

  for (var svc in services) {
    var serviceType = cb.refer(svc.service.symbolName, svc.service.library);

    var exposeAs = svc.exposeAs;
    cb.Reference? exposeAsReference;
    if (exposeAs != null) {
      exposeAsReference = cb.refer(exposeAs.symbolName, exposeAs.library);
    }

    if (svc.preload) {
      preloadServices.add(exposeAsReference ?? serviceType);
    }
  }

  return cb.Method((m) {
    m
      ..annotations.add(cb.refer('override'))
      ..name = providePreloadedTypes$.symbol
      ..returns = listOfT(typeT)
      ..body = cb.literalList(preloadServices).returned.statement;
  });
}
