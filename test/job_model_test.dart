import 'package:thequeue/thequeue.dart';
import 'package:test/test.dart';

class TestModel extends JobModel {
  int jobInt;
  String jobString;
}

void main() {
  group('JobModel', () {
    TestModel jobModel;

    setUp(() {
      jobModel = TestModel();
    });

    test('should serialize JobModel to string', () {
      jobModel.jobInt = 10;
      jobModel.jobString = 'jobString';

      final encodedString = jobModel.serializeToJsonString();

      expect(encodedString, allOf([isA<String>(), isNotEmpty]));
    });

    test('should populate JobModel fields from string', () {
      final jobString = '{"jobInt":10,"jobString":"jobString"}';

      jobModel.serializeFromJsonString(jobString);

      expect(jobModel.jobInt, allOf(isNotNull, equals(10)));
      expect(jobModel.jobString, allOf(isNotNull, equals('jobString')));
    });
  });
}
