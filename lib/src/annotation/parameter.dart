import '../service_provider.dart';

/// Provide an alternative parameter binding
@Deprecated('Use @Inject(parameter: "name") instead.')
class Parameter {
  /// The [name] of the bound parameter inside [ServiceProvider.parameters].
  final String name;

  /// Creates a new parameter annotation.
  const Parameter(this.name);
}
