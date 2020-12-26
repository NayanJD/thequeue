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

  redis.Commands _commands;

  redis.Commands _blockingCommands;

  Logger _logger;

  bool _isClosed = true;

  Future _initializing;

  String get _redisQueueName => ['thequeue', 'queue', _queueName].join(':');

  bool get isClosed => _isClosed;

  Future init(String connectionString) async {
    //conectionString should always be provided
    if (connectionString == null) {
      throw StateError(
          'connectionString should be provided if shouldApplyAuth is true for SimpleQueue');
    }

    final client = await redis.Client.connect(connectionString);
    final blockingClient = await redis.Client.connect(connectionString);

    //Set commands
    _commands = client.asCommands<String, String>();
    _blockingCommands = blockingClient.asCommands<String, String>();

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

  void start() async {
    await _initializing;

    if (_isClosed) {
      return;
    } else {
      process();
    }
  }

  void process() async {
    if (_isClosed) {
      return;
    }

    final listPopResult = await _commands.blpop(key: _redisQueueName);

    T jobModel = Activator.createInstance(T);

    jobModel.serializeFromJsonString(listPopResult.value);

    try {
      await execute(jobModel);
    } catch (error, stacktrace) {
      _logger.severe(error);
      _logger.severe(stacktrace);
    }

    process();
  }

  void close() {
    _isClosed = true;
  }

  Future<void> execute(T jobModel);
}
