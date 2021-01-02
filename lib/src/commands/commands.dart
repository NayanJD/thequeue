import 'dart:io' show Platform, Directory, File;
import 'package:path/path.dart'
    show dirname, basenameWithoutExtension, extension;

Map<String, String> memoisedScriptMap = null;

Future<Map<String, String>> readLua() async {
  if (memoisedScriptMap != null) {
    return memoisedScriptMap;
  }

  // final scriptDirectory = dirname(Platform.script.path);

  //Need a way to find the script's current directory
  //Platform.script.path does not work in running test
  final directory = Directory('./lib/src/commands');

  final fileSystemEntities = directory.list();

  final result = <String, String>{};

  await for (var fileSystemEntity in fileSystemEntities) {
    if (fileSystemEntity is File) {
      final filePath = fileSystemEntity.path;
      final fileExtension = extension(filePath);
      final fileBasename = basenameWithoutExtension(filePath);

      if (fileExtension == '.lua') {
        result[fileBasename] = await fileSystemEntity.readAsString();
      }
    }
  }

  memoisedScriptMap = result;

  return result;
}
