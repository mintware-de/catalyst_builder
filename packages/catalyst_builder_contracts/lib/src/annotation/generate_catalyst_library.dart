/// Mark the file which contains this annotation to generate a library
/// that exports all services in the current package.
class GenerateCatalystLibrary {
  /// Set this property for setting the variable name of the generated
  /// services map.
  final String libraryName;

  /// Set this property to include services from dependencies.
  /// By default, only services from the current package are included.
  final bool includeDependencies;

  /// Mark this file to generate a services library
  const GenerateCatalystLibrary({
    this.libraryName = 'catalystServices',
    this.includeDependencies = false,
  });
}