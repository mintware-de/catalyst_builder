import 'package:code_builder/code_builder.dart' as cb;

import '../../symbols.dart';

/// Template for the constructor
cb.Constructor buildProviderConstructor(String pluginClassName) {
  return cb.Constructor((ctor) => ctor
    ..body = cb.Block.of([
      applyPlugin$.call([cb.refer(pluginClassName).call([])]).statement,
    ]));
}
