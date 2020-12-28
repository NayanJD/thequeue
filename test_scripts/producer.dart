import './consumer.dart';

main() {
  final testQueue = TestQueue();

  var testModel = TestModel();

  for (int i = 0; i < 1000; i++) {
    testModel = TestModel();
    testModel.jobInt = i;
    testModel.jobString = 'string';
    testQueue.addJob(testModel);
  }
  // testModel.jobInt = 1;
  // testModel.jobString = 'string';
  // testQueue.addJob(testModel);

  // testModel = TestModel();
  // testModel.jobInt = 3;
  // testModel.jobString = 'string';
  // testQueue.addJob(testModel);
}
