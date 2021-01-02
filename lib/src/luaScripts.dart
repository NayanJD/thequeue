import 'dart:convert';
import 'package:thequeue/src/commands/commands.dart';
import 'package:dartis/dartis.dart' as redis;
import './logger.dart';

Future<T> runLuaScript<T>(String scriptName, redis.Commands commands,
    {List<String> keys, List<String> args, redis.Mapper mapper}) async {
  final scriptMap = await readLua();

  final luaScript = scriptMap[scriptName].stringifiedScript;
  final sha1Hash = scriptMap[scriptName].sha1Hash;

  var isScriptRememberedByRedis = true;

  T result;
  try {
    result = await commands.evalsha<T>(sha1Hash,
        keys: keys ?? <String>[], args: args ?? [], mapper: mapper);

    logger.finer('addJob script remembered.');
  } on redis.RedisException catch (error) {
    if (error.message.contains('NOSCRIPT')) {
      logger.finer('addJob script not remembered');
      isScriptRememberedByRedis = false;
    } else {
      rethrow;
    }
  }

  if (!isScriptRememberedByRedis) {
    logger.finer('addJob script running as eval');
    result = await commands.eval<T>(luaScript,
        keys: keys ?? <String>[], args: args ?? [], mapper: mapper);
  }

  return result;
}

class MoveToActiveScriptMapper implements redis.Mapper<Map<String, String>> {
  @override
  Map<String, String> map(redis.Reply reply, redis.RedisCodec codec) {
    final result = <String, String>{};

    if (reply is redis.ArrayReply) {
      final replyArray = reply.array;

      for (var i = 0; i < replyArray.length; i += 2) {
        if (replyArray[i] is redis.BulkReply &&
            replyArray[i + 1] is redis.BulkReply) {
          final key = utf8.decode((replyArray[i] as redis.BulkReply).bytes);
          final value =
              utf8.decode((replyArray[i + 1] as redis.BulkReply).bytes);

          result[key] = value;
        }
      }
    }

    return result;
  }
}
