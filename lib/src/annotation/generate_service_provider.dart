/// Mark the file which contains this annotation as the entry point.
class GenerateServiceProvider {
  final String providerClassName;
  final bool includePackageDependencies;

  /// Mark this file as the entry point for the service container
  const GenerateServiceProvider({
    this.providerClassName = 'DefaultServiceProvider',
    this.includePackageDependencies = false,
  });
}
