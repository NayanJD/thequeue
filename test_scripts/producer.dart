import './consumer.dart';

main() {
  final testQueue = TestQueue();

  var testModel = TestModel();

  testModel.jobInt = 1;
  testModel.jobString = 'string';
  testQueue.addJob(testModel);

  testModel = TestModel();
  testModel.jobInt = 2;
  testModel.jobString = 'string';
  testQueue.addJob(testModel);

  testModel = TestModel();
  testModel.jobInt = 2;
  testModel.jobString = 'string';
  testQueue.addJob(testModel);
}
