import 'package:code_builder/code_builder.dart' as cb;

import '../../../dto/dto.dart';
import '../../helper.dart';
import '../../symbols.dart';

/// Template for boot()
cb.Method bootTemplate(
  List<ExtractedService> services,
) {
  return cb.Method((m) {
    var preloadServices = <cb.Code>[];

    for (var svc in services) {
      var serviceType = cb.refer(svc.service.symbolName, svc.service.library);

      var exposeAs = svc.exposeAs;
      cb.Reference? exposeAsReference;

      if (exposeAs != null) {
        exposeAsReference = cb.refer(exposeAs.symbolName, exposeAs.library);
      }
      if (svc.preload) {
        preloadServices.add(
          resolve$.call([], {}, [exposeAsReference ?? serviceType]).statement,
        );
      }
    }

    m
      ..name = boot$.symbol
      ..returns = voidT
      ..annotations.add(cb.refer('override'))
      ..body = cb.Block.of([
        IfBuilder(booted$)
            .then(providerAlreadyBootedExceptionT.constInstance([]).thrown)
            .code,
        assign(booted$, cb.literalTrue).statement,
        ...preloadServices
      ]);
  });
}
