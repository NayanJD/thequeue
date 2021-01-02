import 'package:thequeue/thequeue.dart';
import 'package:dartis/dartis.dart' as redis;
import 'package:thequeue/src/luaScripts.dart';

class Job<T extends JobModel> {
  Job(this.jobModel, this._commands);

  T jobModel;

  final redis.Commands _commands;

  bool _isBeingProcessed = false;

  bool get isBeingProcessed => _isBeingProcessed;

  set isBeingProcessed(value) => _isBeingProcessed = value;

  Future<int> createJob(QueueKeys queueKeys, String queueKeyPrefix) async {
    final jobId = await runLuaScript<int>('addJob', _commands, keys: <String>[
      queueKeys.jobId,
      queueKeys.waitQueue
    ], args: [
      queueKeyPrefix,
      jobModel.serializeToJsonString(),
      DateTime.now().millisecondsSinceEpoch.toString()
    ]);

    // print(jobId);

    return jobId;
  }
}
