import 'package:code_builder/code_builder.dart' as cb;

import '../../../dto/dto.dart';
import '../../helper.dart';
import '../../symbols.dart';

/// Template for boot()
cb.Method bootTemplate(
  List<ExtractedService> services,
) {
  return cb.Method((m) {
    var typeV = const cb.Reference('type');

    m
      ..name = boot$.symbol
      ..returns = voidT
      ..annotations.add(cb.refer('override'))
      ..body = cb.Block.of([
        IfBuilder(booted$)
            .then(providerAlreadyBootedExceptionT.constInstance([]).thrown)
            .code,
        assign(booted$, cb.literalTrue).statement,
        ForEachBuilder(preloadedTypes$, typeV)
            .finalize(tryResolveInternal$.call([typeV], {}, [dynamicT.type]))
            .code,
      ]);
  });
}
