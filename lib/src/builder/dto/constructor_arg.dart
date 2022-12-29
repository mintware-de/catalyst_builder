import 'inject_annotation.dart';

/// Represents an argument in the constructor
class ConstructorArg {
  /// The name of the argument
  final String name;

  /// The arguments default value
  final String defaultValue;

  /// True if the parameter is optional.
  final bool isOptional;

  /// True if the parameter is a positional parameter.
  final bool isPositional;

  /// True if the parameter is a named parameter.
  final bool isNamed;

  /// Overwrite the default parameter name
  final String? boundParameter;

  final InjectAnnotation? inject;

  /// Create a ConstructorArg.
  const ConstructorArg({
    required this.name,
    required this.defaultValue,
    required this.isOptional,
    required this.isPositional,
    required this.isNamed,
    required this.boundParameter,
    required this.inject,
  });

  /// Creates a new instance from the result of [toJson].
  factory ConstructorArg.fromJson(Map<String, dynamic> json) {
    return ConstructorArg(
      name: json['name'],
      defaultValue: json['defaultValue'],
      isOptional: json['isOptional'],
      isPositional: json['isPositional'],
      isNamed: json['isNamed'],
      boundParameter: json['boundParameter'],
      inject: json['inject'] != null
          ? InjectAnnotation.fromJson(json['inject'])
          : null,
    );
  }

  /// Dumps the object in a map that can be used in [ConstructorArg.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isOptional': isOptional,
      'isNamed': isNamed,
      'isPositional': isPositional,
      'defaultValue': defaultValue,
      'boundParameter': boundParameter,
      'inject': inject?.toJson(),
    };
  }
}
