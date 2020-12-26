import 'dart:mirrors';
import 'dart:convert';

class JobModel {
  void serializeFromJsonString(String jsonString) {
    final object = jsonDecode(jsonString);

    final mirror = reflect(this);
    for (var declaration in mirror.type.declarations.values) {
      if (declaration is VariableMirror) {
        final variableName = MirrorSystem.getName(declaration.simpleName);

        final variableSymbol = declaration.type.simpleName;

        if (!object.containsKey(variableName) || object[variableName] == null) {
          continue;
        }

        try {
          if (declaration.type.isSubtypeOf(reflectType(Iterable))) {
            var iterableMirror =
                (declaration.type as ClassMirror).newInstance(Symbol(''), []);

            var objectIterable = object[variableName] as Iterable<dynamic>;

            for (var value in objectIterable) {
              iterableMirror.invoke(Symbol('add'), [value]);
            }

            mirror.setField(declaration.simpleName, iterableMirror.reflectee);
          } else if (variableSymbol == Symbol('DateTime')) {
            mirror.setField(declaration.simpleName,
                DateTime.parse(object[variableName] as String));
          } else {
            mirror.setField(declaration.simpleName, object[variableName]);
          }
        } catch (error) {
          //Error while parsing $variableName:: ${error.toString()}
          //Swallow the error for now
        }
      }
    }
  }

  String serializeToJsonString() {
    final mirror = reflect(this);

    final result = <String, dynamic>{};
    for (var declaration in mirror.type.declarations.values) {
      if (declaration is VariableMirror) {
        final variableSymbol = declaration.type.simpleName;

        if (variableSymbol == Symbol('DateTime')) {
          result[MirrorSystem.getName(declaration.simpleName)] =
              (mirror.getField(declaration.simpleName).reflectee as DateTime)
                  .toIso8601String();
        } else {
          result[MirrorSystem.getName(declaration.simpleName)] =
              mirror.getField(declaration.simpleName).reflectee;
        }
      }
    }

    return jsonEncode(result);
  }
}
