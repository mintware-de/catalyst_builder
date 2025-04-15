/// Mark the file which contains this annotation as the entry point.
class GenerateServiceContainerPlugin {
  /// Set this property for setting the class name of the generated
  /// service container plugin.
  final String pluginClassName;

  /// Mark this file as the entry point for the plugin
  const GenerateServiceContainerPlugin({
    required this.pluginClassName,
  });
}
