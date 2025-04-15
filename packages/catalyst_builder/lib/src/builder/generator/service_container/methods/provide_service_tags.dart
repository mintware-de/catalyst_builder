import 'package:code_builder/code_builder.dart' as cb;

import '../../../dto/dto.dart';
import '../../symbols.dart';

/// Template for provideServiceTags
cb.Method provideServiceTagsTemplate(List<ExtractedService> services) {
  var servicesBySymbol = <cb.Code, List<cb.Reference>>{};
  var knownTags = <String, cb.Code>{};

  for (var svc in services) {
    var serviceType = cb.refer(svc.service.symbolName, svc.service.library);

    for (var tag in svc.tags) {
      if (!knownTags.containsKey(tag)) {
        knownTags[tag] = cb.Code('#$tag');
      }
      var s = knownTags[tag];
      if (s == null) {
        continue;
      }
      if (!servicesBySymbol.containsKey(s)) {
        servicesBySymbol[s] = [];
      }
      servicesBySymbol[s]?.add(serviceType);
    }
  }

  return cb.Method((m) {
    m
      ..annotations.add(cb.refer('override'))
      ..name = provideServiceTags$.symbol
      ..returns = mapOfT(symbolT, listOfT(typeT))
      ..body = cb
          .literalMap(servicesBySymbol, symbolT, listOfT(typeT))
          .returned
          .statement;
  });
}
