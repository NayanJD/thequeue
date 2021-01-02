import 'dart:io' show Platform, Directory, File;
import 'dart:convert';
import 'package:path/path.dart'
    show dirname, basenameWithoutExtension, extension;
import 'package:crypto/crypto.dart';

class LuaScript {
  final String stringifiedScript;
  final String sha1Hash;

  LuaScript(this.stringifiedScript, this.sha1Hash);
}

Map<String, LuaScript> memoisedScriptMap = null;

Future<Map<String, LuaScript>> readLua() async {
  if (memoisedScriptMap != null) {
    return memoisedScriptMap;
  }

  // final scriptDirectory = dirname(Platform.script.path);

  //Need a way to find the script's current directory
  //Platform.script.path does not work in running test
  final directory = Directory('./lib/src/commands');

  final fileSystemEntities = directory.list();

  final result = <String, LuaScript>{};

  await for (var fileSystemEntity in fileSystemEntities) {
    if (fileSystemEntity is File) {
      final filePath = fileSystemEntity.path;
      final fileExtension = extension(filePath);
      final fileBasename = basenameWithoutExtension(filePath);

      if (fileExtension == '.lua') {
        // result[fileBasename] = await fileSystemEntity.readAsString();

        final stringifiedScript = await fileSystemEntity.readAsString();
        final sha1Hash = sha1.convert(utf8.encode(stringifiedScript));

        result[fileBasename] =
            LuaScript(stringifiedScript, sha1Hash.toString());
      }
    }
  }

  memoisedScriptMap = result;

  return result;
}
