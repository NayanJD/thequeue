import 'package:thequeue/thequeue.dart';

class TestModel extends JobModel {
  int jobInt;
  String jobString;
}

class TestQueue extends Queue<TestModel> {
  TestQueue() : super('testQueue', 'redis://localhost:6379');

  Future<void> execute(TestModel model) async {
    print('execute start: ${model.jobInt}');

    await Future.delayed(Duration(seconds: 1));

    // print('execute done: ${model.jobInt}');
  }
}

main() async {
  final testQueue = TestQueue();

  testQueue.start(concurrency: 2);

  // await testQueue.doneInitializing;

  // await Future.delayed(Duration(seconds: 3));

  // print('Closing');
  // await testQueue.close();
}
