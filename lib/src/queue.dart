import 'dart:async';

import 'package:thequeue/src/activator.dart';
import 'package:thequeue/thequeue.dart';
import 'package:dartis/dartis.dart' as redis;

class QueueOptions {
  final String _keyPrefix;

  String get keyPrefix => _keyPrefix;

  const QueueOptions(this._keyPrefix);

  Map<String, dynamic> toJson() {
    return {'keyPrefix': _keyPrefix};
  }
}

abstract class Queue<T extends JobModel> {
  Queue(this._queueName, String connectionString,
      {this.options = const QueueOptions('thequeue')}) {
    _initializing = init(connectionString);
  }

  final String _queueName;

  final QueueOptions options;

  redis.Client _client;

  redis.Client _bclient;

  redis.Commands _commands;

  redis.Commands _blockingCommands;

  Logger _logger;

  bool _isClosed = true;

  Future _initializing;

  Future get doneInitializing => _initializing;

  String get _redisQueueName => [options.keyPrefix, 'queue', _queueName].join(':');

  bool get isClosed => _isClosed;

  final List<StreamSubscription<Job<T>>> _jobStreamSubscriptions = [];

  Future init(String connectionString) async {
    //conectionString should always be provided
    if (connectionString == null) {
      throw StateError(
          'connectionString should be provided if shouldApplyAuth is true for SimpleQueue');
    }

    _client = await redis.Client.connect(connectionString);
    _bclient = await redis.Client.connect(connectionString);

    //Set commands
    _commands = _client.asCommands<String, String>();
    _blockingCommands = _bclient.asCommands<String, String>();

    //Get username:password from redis://usernam:password@localhost:6379
    final uri = Uri.parse(connectionString);

    //If auth should be applied
    if (uri.userInfo != null && uri.userInfo != '') {
      final password = uri.userInfo.split(':');

      if (password.length == 2) {
        //Send auth <password> command to redis
        await _commands.auth(password[1]);
        await _blockingCommands.auth(password[1]);
      }
    }

    _isClosed = false;
  }

  void start({int concurrency = 1}) async {
    await _initializing;

    if (_isClosed) {
      return;
    } else {
      final stream = jobStream().asBroadcastStream();

      while (concurrency > 0) {
        StreamSubscription<Job<T>> streamSubscription;

        streamSubscription = stream.listen((Job<T> job) async  {

          streamSubscription.pause();

          await process(job);

          streamSubscription.resume();
        });

        _jobStreamSubscriptions.add(streamSubscription);
        concurrency--;
      }
    }
  }

  void close() async {
    for (var subscription in _jobStreamSubscriptions) {
      await subscription.cancel();
    }

    await _client.disconnect();
    await _bclient.disconnect();
  }

  // void process() async {
  //   if (_isClosed) {
  //     return;
  //   }

  //   final listPopResult = await _commands.blpop(key: _redisQueueName);

  //   T jobModel = Activator.createInstance(T);

  //   jobModel.serializeFromJsonString(listPopResult.value);

  //   try {
  //     await execute(jobModel);
  //   } catch (error, stacktrace) {
  //     _logger.severe(error);
  //     _logger.severe(stacktrace);
  //   }

  //   process();
  // }

  void process(Job<T> job) async {

    if(!job.isBeingProcessed){
      job.isBeingProcessed = true;
    }else {
      return;
    }

    try {
      await execute(job.jobModel);
    } catch (error, stacktrace) {
      _logger.severe(error);
      _logger.severe(stacktrace);
    }
  }

  Stream<Job<T>> jobStream() async* {
    if (_isClosed) {
      return;
    }

    while (true) {
      final listPopResult = await _blockingCommands.blpop(key: _redisQueueName, timeout: 5);

      // print('broken from blpop');

      if(listPopResult != null){
      T jobModel = Activator.createInstance(T);

      jobModel.serializeFromJsonString(listPopResult.value);

      yield Job(jobModel);
      }
    }
  }

  // void close() {
  //   _isClosed = true;
  // }

  //This method would be called by api server to
  //add job to queue
  Future<void> addJob(T model) async {
    //wait for initialization to finish
    await _initializing;

    //push job to redis list
    await _commands.rpush(_redisQueueName,
        value: model.serializeToJsonString());
  }

  Future<void> execute(T jobModel);
}
