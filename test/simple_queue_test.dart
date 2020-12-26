import 'package:thequeue/thequeue.dart';
import 'package:dartis/dartis.dart' as redis;
import 'package:test/test.dart';

class TestModel extends JobModel {
  int jobInt;
  String jobString;
}

void main() {
  redis.Client queueClient;
  redis.Client testClient;
  final testCommands = testClient.asCommands<String, String>();
  SimpleQueue<TestModel> queue;

  group('Queue', () {
    setUp(() async {
      queueClient = await redis.Client.connect('redis://localhost:6379');
      testClient = await redis.Client.connect('redis://localhost:6379');
      queue = SimpleQueue<TestModel>('testQueue', queueClient);
    });

    test('should serialize JobModel to string', () {
      var testInteger = 0;

      var queueName = ['thequeue', 'queue', 'testQueue'].join(':');

      await testCommands.rpush(queueName, value: model.serializeToJsonString());
      expect(encodedString, allOf([isA<String>(), isNotEmpty]));
    });
  });
}
