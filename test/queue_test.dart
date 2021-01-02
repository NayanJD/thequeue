import 'dart:async';
import 'package:thequeue/thequeue.dart';
import 'package:dartis/dartis.dart' as redis;
import 'package:test/test.dart';

class TestModel extends JobModel {
  int jobInt;
  String jobString;
}

class TestQueue extends Queue<TestModel> {
  TestQueue(this.completer) : super('testQueue', 'redis://localhost:6379');

  Completer completer;
  Future<void> execute(TestModel model) {
    print('execute: ${model}');

    completer.complete();
  }
}

void main() {
  redis.Client queueClient;
  redis.Client testClient;
  Queue<TestModel> queue;

  group('Queue', () {
    setUp(() async {
      // queueClient = await redis.Client.connect('redis://localhost:6379');
      // testClient = await redis.Client.connect('redis://localhost:6379');
    });

    test('should execute added jobs', () async {
      final _completer = Completer();

      queue = TestQueue(_completer);

      queue.start();

      await queue.doneInitializing;

      final testModel = TestModel();
      testModel.jobInt = 1;
      testModel.jobString = 'string';

      await queue.addJob(testModel);

      return _completer.future;
      // expect(encodedString, allOf([isA<String>(), isNotEmpty]));
    }, timeout: Timeout(Duration(seconds: 5)));
  });
}
