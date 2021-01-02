import 'package:thequeue/src/commands/commands.dart';
import 'package:dartis/dartis.dart' as redis;

Future<T> runLuaScript<T>(String scriptName, redis.Commands commands,
    {List<String> keys, List<String> args}) async {
  final scriptMap = await readLua();

  final luaScript = scriptMap[scriptName].stringifiedScript;
  final sha1Hash = scriptMap[scriptName].sha1Hash;

  var isScriptRememberedByRedis = true;

  T result;
  try {
    result = await commands.evalsha<T>(sha1Hash, keys: keys, args: args);

    print('addJob script remembered.');
  } on redis.RedisException catch (error) {
    if (error.message.contains('NOSCRIPT')) {
      print('addJob script not remembered');
      isScriptRememberedByRedis = false;
    } else {
      rethrow;
    }
  }

  if (!isScriptRememberedByRedis) {
    print('addJob script running as eval');
    result = await commands.eval<T>(luaScript, keys: keys, args: args);
  }

  return result;
}
