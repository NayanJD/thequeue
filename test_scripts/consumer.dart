import 'package:thequeue/thequeue.dart';

class TestModel extends JobModel {
  int jobInt;
  String jobString;
}

class TestQueue extends Queue<TestModel> {
  TestQueue() : super('testQueue', 'redis://localhost:6379');

  Future<void> execute(TestModel model) {
    print('execute: ${model}');
  }
}

main() async {
  final testQueue = TestQueue();

  testQueue.start(concurrency: 3);

  await testQueue.doneInitializing;

  await Future.delayed(Duration(seconds: 3));

  print('Closing');
  await testQueue.close();
}
