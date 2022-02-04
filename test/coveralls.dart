import './unit/annotation/parameter_test.dart' as parameter_test;
import './unit/annotation/preload_test.dart' as preload_test;
import './unit/annotation/service_map_test.dart' as service_map_test;
import './unit/annotation/service_test.dart' as service_test;
import './unit/builder/dto/constructor_arg_test.dart' as constructor_arg_test;
import './unit/builder/dto/extracted_service_test.dart'
    as extracted_service_test;
import './unit/builder/dto/preflight_part_test.dart' as preflight_part_test;
import './unit/builder/dto/symbol_reference_test.dart' as symbol_reference_test;
import './unit/service_descriptor_test.dart' as service_descriptor_test;

void main() {
  service_test.main();
  parameter_test.main();
  preload_test.main();
  preflight_part_test.main();
  symbol_reference_test.main();
  constructor_arg_test.main();
  extracted_service_test.main();
  service_map_test.main();
  service_descriptor_test.main();
}
