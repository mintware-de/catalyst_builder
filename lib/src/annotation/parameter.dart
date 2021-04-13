import '../../catalyst_builder.dart';

/// Provide an alternative parameter binding
class Parameter {
  /// The [name] of the bound parameter inside [ServiceProvider.parameters].
  final String name;

  /// Creates a new parameter annotation.
  const Parameter(this.name);
}
