import 'dart:convert';

import 'package:thequeue/src/activator.dart';
import 'package:thequeue/thequeue.dart';
import 'package:dartis/dartis.dart' as redis;
import 'package:thequeue/src/luaScripts.dart';

class Job<T extends JobModel> {
  Job(this.id, this.jobModel);

  int id;

  T jobModel;

  // final redis.Commands _commands;

  bool _isBeingProcessed = false;

  bool get isBeingProcessed => _isBeingProcessed;

  set isBeingProcessed(value) => _isBeingProcessed = value;

  static Future<int> createJob(QueueKeys queueKeys, String queueKeyPrefix,
      redis.Commands _commands, JobModel jobModel) async {
    final jobId = await runLuaScript<int>('addJob', _commands, keys: <String>[
      queueKeys.jobId,
      queueKeys.waitQueue
    ], args: [
      queueKeyPrefix,
      jobModel.serializeToJsonString(),
      DateTime.now().millisecondsSinceEpoch.toString()
    ]);

    return jobId;
  }

  Job.fromJson(Map<String, String> json) {
    final stringifiedJobData = json['data'];

    T jobModel = Activator.createInstance(T);

    jobModel.serializeFromJsonString(stringifiedJobData);

    id = int.parse(json['jobId']);

    this.jobModel = jobModel;
  }
}

Job<T> createJobFromJson<T extends JobModel>(Map<String, String> json) {
  final stringifiedJobData = json['data'];

  final T jobModel = Activator.createInstance(T);

  jobModel.serializeFromJsonString(stringifiedJobData);

  final id = int.parse(json['jobId']);

  return Job<T>(id, jobModel);
}
