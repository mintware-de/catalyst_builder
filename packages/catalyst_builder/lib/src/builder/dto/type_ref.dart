/// Represents a resolvable type reference extracted from a constructor
/// parameter.
///
/// A [TypeRef] is only created for types that can be referenced by name in
/// generated code (interfaces with fully resolvable type arguments).
class TypeRef {
  /// The name of the type. (`Logger`, `List`)
  final String symbolName;

  /// The library where the type is located. `null` for types of `dart:core`.
  final String? library;

  /// The type arguments of this type. (`String` in `List<String>`)
  final List<TypeRef> typeArguments;

  /// True if the type is nullable.
  final bool isNullable;

  /// Create a new [TypeRef].
  const TypeRef({
    required this.symbolName,
    this.library,
    this.typeArguments = const <TypeRef>[],
    this.isNullable = false,
  });

  /// Creates a new instance from the result of [toJson].
  factory TypeRef.fromJson(Map<String, dynamic> json) {
    return TypeRef(
      symbolName: json['symbolName'].toString(),
      library: json['library']?.toString(),
      typeArguments: (json['typeArguments'] as List<dynamic>?)
              ?.map((e) => TypeRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TypeRef>[],
      isNullable: json['isNullable'] == true,
    );
  }

  /// Dumps the object in a map that can be used in [TypeRef.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'symbolName': symbolName,
      'library': library,
      'typeArguments': typeArguments.map((e) => e.toJson()).toList(),
      'isNullable': isNullable,
    };
  }
}
