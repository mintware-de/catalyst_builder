import 'package:code_builder/code_builder.dart' as cb;

/// Short hand method for assignVar.
cb.Code initVar(cb.Reference var$, cb.Expression value$) {
  return value$.assignVar(var$.symbol).statement;
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
      cb.Code('if ('),
      _condition.code,
      cb.Code(') {'),
      body.statement,
      cb.Code('}'),
    ]));
  }
}

/// Helper Extensions
extension ReferenceExtension on cb.Reference {
  /// short hand operator for the index method.
  cb.Expression operator [](cb.Expression index) {
    return this.index(index);
  }
}
