import 'package:code_builder/code_builder.dart' as cb;

import '../../helper.dart';
import '../../symbols.dart';

/// Template for _ensureBooted
final ensureBootedTemplate = cb.Method((m) {
  m
    ..name = ensureBoot$.symbol
    ..returns = voidT
    ..body = cb.Block.of([
      IfBuilder(booted$.equalTo(cb.literalFalse))
          .then(providerNotBootedExceptionT.constInstance([]).thrown)
          .code,
    ]);
});
