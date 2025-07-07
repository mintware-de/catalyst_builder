import 'package:code_builder/code_builder.dart' as cb;

import '../../dto/dto.dart';
import '../symbols.dart';

/// Builds the services map for the library
cb.Field buildServicesMap(String libraryName, List<ExtractedService> services) {
  final mapEntries = <cb.Expression, cb.Expression>{};

  for (final service in services) {
    final serviceType =
        cb.refer(service.service.symbolName, service.service.library);
    final serviceInstance = cb.CodeExpression(cb.Code('_i1.Service()'));

    mapEntries[serviceType] = serviceInstance;
  }

  return cb.Field((f) => f
    ..name = libraryName
    ..type = mapOfT(typeT, serviceT)
    ..modifier = cb.FieldModifier.constant
    ..assignment = cb.literalMap(mapEntries).code);
}

