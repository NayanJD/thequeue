import 'package:thequeue/thequeue.dart';

class Job<T extends JobModel> {
  Job(this.jobModel);

  T jobModel;

  bool _isBeingProcessed = false;

  bool get isBeingProcessed => _isBeingProcessed;

  set isBeingProcessed(value) => _isBeingProcessed = value;
}