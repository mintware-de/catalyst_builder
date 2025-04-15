import 'package:code_builder/code_builder.dart' as cb;

import '../../../dto/dto.dart';
import '../../symbols.dart';

/// Template for provideExposes
cb.Method provideExposesTemplate(List<ExtractedService> services) {
  var exposeAsData = <cb.Reference, cb.Reference>{};

  for (var svc in services) {
    var serviceType = cb.refer(svc.service.symbolName, svc.service.library);

    var exposeAs = svc.exposeAs;
    if (exposeAs != null) {
      cb.Reference? exposeAsReference =
          cb.refer(exposeAs.symbolName, exposeAs.library);
      exposeAsData[exposeAsReference] = serviceType;
    }
  }

  return cb.Method((m) {
    m
      ..annotations.add(cb.refer('override'))
      ..name = provideExposes$.symbol
      ..returns = mapOfT(typeT, typeT)
      ..body = cb.literalMap(exposeAsData, typeT, typeT).returned.statement;
  });
}
