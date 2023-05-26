import 'package:catalyst_builder/catalyst_builder.dart';

import './src/manually_wired_service.dart';

export './public_api.dart';
export './src/manually_wired_service.dart';
export 'example.catalyst_builder.g.dart';

/**
 * Export the catalyst_exports that the watch command can recompile the
 * ServiceProvider when the dependencies changes.
 */
export 'relative_deps_exports.dart';

@Preload()
@GenerateServiceProvider()
@ServiceMap(services: {
  ManuallyWiredServiceImplementation: Service(
    exposeAs: ManuallyWiredService,
  ),
})
void main() {}
