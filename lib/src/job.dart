import 'package:thequeue/src/commands/commands.dart';
import 'package:thequeue/thequeue.dart';
import 'package:dartis/dartis.dart' as redis;

class Job<T extends JobModel> {
  Job(this.jobModel, this._commands);

  T jobModel;

  final redis.Commands _commands;

  bool _isBeingProcessed = false;

  bool get isBeingProcessed => _isBeingProcessed;

  set isBeingProcessed(value) => _isBeingProcessed = value;

  Future<void> createJob(QueueKeys queueKeys) async {
    final scriptMap = await readLua();

    final jobId = await _commands.eval<int>(scriptMap['addJob'], keys: <String>[
      queueKeys.jobId,
      queueKeys.waitQueue
    ], args: [
      'prefix',
      jobModel.serializeToJsonString(),
      DateTime.now().millisecondsSinceEpoch.toString()
    ]);

    print(jobId);
  }
}
