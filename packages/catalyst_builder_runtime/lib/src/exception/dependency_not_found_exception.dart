import 'catalyst_builder_exception.dart';

/// An exception that is thrown when a service of the type [service]
/// was not found.
class DependencyNotFoundException extends CatalystBuilderException {
  /// The service that require the dependency.
  final Type requiredBy;

  /// The name of the parameter.
  final String parameterName;

  /// Creates a new [DependencyNotFoundException] object.
  const DependencyNotFoundException(
    this.requiredBy,
    this.parameterName, [
    CatalystBuilderException? inner,
  ]) : super(
          'One or more dependencies of $requiredBy was not found. '
          '(Parameter: $parameterName)',
          inner,
        );
}
