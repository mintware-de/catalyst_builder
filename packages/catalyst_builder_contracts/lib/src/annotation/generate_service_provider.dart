/// Mark the file which contains this annotation as the entry point.
class GenerateServiceProvider {
  /// Set this property for changing the class name of the generated
  /// service provider.
  final String providerClassName;

  /// Set this property for changing the class name of the generated
  /// service provider plugin.
  ///
  /// If you're developing a third party plugin you need to set this property
  /// otherwise the plugin class is not public since the default value is
  /// prefixed by _;
  final String pluginClassName;

  /// Mark this file as the entry point for the service container
  const GenerateServiceProvider({
    this.providerClassName = 'DefaultServiceProvider',
    String? pluginClassName,
  }) : pluginClassName = pluginClassName ?? "_${providerClassName}Plugin";
}
