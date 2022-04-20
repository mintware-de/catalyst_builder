import 'package:code_builder/code_builder.dart' as cb;

/// Short hand method for assignVar.
cb.Code initVar(cb.Reference var$, cb.Expression value$) {
  return value$.assignVar(var$.symbol!).statement;
}

/// Short hand method for assignNullAware.
cb.Expression fallbackIfNull(cb.Reference var$, cb.Expression fallbackValue) {
  return var$.assignNullAware(fallbackValue);
}

/// Short hand method for assignN.
cb.Expression assign(cb.Expression var$, cb.Expression value$) {
  return var$.assign(value$);
}

/// Helper class for building If-Conditions
class IfBuilder {
  final cb.Expression _condition;

  /// Creates an [IfBuilder] with the given [_condition].
  IfBuilder(this._condition);

  /// Short hand method for returning the [result] in the if body.
  cb.Code thenReturn(cb.Expression result) {
    return then(result.returned).code;
  }

  /// Executes the [body] in the if body.
  cb.Expression then(cb.Expression body) {
    return cb.CodeExpression(cb.Block.of([
      const cb.Code('if ('),
      _condition.code,
      const cb.Code(') {'),
      body.statement,
      const cb.Code('}'),
    ]));
  }
}

class ForEachBuilder {
  final cb.Expression _collection;
  final cb.Expression _var;

  /// Creates an [ForEachBuilder] with the given [_collection].
  ForEachBuilder(this._collection, this._var);

  /// Executes the [body] in the if body.
  cb.Expression finalize(cb.Expression body) {
    return cb.CodeExpression(cb.Block.of([
      const cb.Code('for (var '),
      _var.code,
      const cb.Code(' in '),
      _collection.code,
      const cb.Code(') {'),
      body.statement,
      const cb.Code('}'),
    ]));
  }
}

/// Helper class for building Try-Catch-Blocks
cb.Expression try$(Function(_TryCatchBuilder) builder) {
  return _TryCatchBuilder(builder)._build();
}

class _TryCatchBuilder {
  /// The body of the Try-Block
  cb.Code? tryBody;

  /// The Catch Blocks.
  /// Key = The condition
  /// Value = The catch block
  Map<cb.Code, cb.Code> catchBodies = {};

  /// The body of the Finally-Block
  cb.Code? finallyBody;

  /// Creates a new
  _TryCatchBuilder(Function(_TryCatchBuilder) builder) {
    builder(this);
  }

  /// Build the Try-Catch-Block
  cb.Expression _build() {
    return cb.CodeExpression(cb.Block.of([
      _buildTryBlock(),
      _buildCatchBlocks(),
      _buildFinallyBlock(),
    ]));
  }

  cb.Block _buildTryBlock() {
    var statements = <cb.Code>[];
    if (tryBody != null) {
      statements = [
        const cb.Code('try {'),
        tryBody!,
        const cb.Code('}'),
      ];
    }
    return cb.Block.of(statements);
  }

  cb.Block _buildCatchBlocks() {
    var statements = <cb.Code>[];

    for (var kvp in catchBodies.entries) {
      statements.addAll([
        const cb.Code('catch ('),
        kvp.key,
        const cb.Code(') {'),
        kvp.value,
        const cb.Code('}'),
      ]);
    }

    return cb.Block.of(statements);
  }

  cb.Block _buildFinallyBlock() {
    var statements = <cb.Code>[];
    if (finallyBody != null) {
      statements = [
        const cb.Code('finally {'),
        finallyBody!,
        const cb.Code('}'),
      ];
    }
    return cb.Block.of(statements);
  }
}

/// Helper Extensions
extension ReferenceExtension on cb.Reference {
  /// short hand operator for the index method.
  cb.Expression operator [](cb.Expression index) {
    return this.index(index);
  }
}
