/// Mark the file which contains this annotation as the entry point.
class GenerateServiceProviderPlugin {
  /// Set this property for setting the class name of the generated
  /// service provider plugin.
  final String pluginClassName;

  /// Mark this file as the entry point for the plugin
  const GenerateServiceProviderPlugin({
    required this.pluginClassName,
  });
}
