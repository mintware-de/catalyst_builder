/// Mark the file which contains this annotation as the entry point.
class GenerateServiceProvider {
  /// Set this property for changing the class name of the generated
  /// service provider.
  final String providerClassName;

  /// Set this property to true if you like to include also the services
  /// provided of your dependencies. Otherwise only the services in your
  /// root package will be registered.
  final bool includePackageDependencies;

  /// Mark this file as the entry point for the service container
  const GenerateServiceProvider({
    this.providerClassName = 'DefaultServiceProvider',
    this.includePackageDependencies = false,
  });
}
