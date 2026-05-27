import 'package:flutter_test/flutter_test.dart';
import 'package:submarine_flutter/models/user_session_record.dart';

void main() {
  group('UserSessionRecord', () {
    test('fromJson parses correctly', () {
      final json = {
        "id": 1,
        "userId": 3,
        "transcript": " Move backward 5 meters.",
        "action": "MOVE",
        "direction": "BACKWARD",
        "value": 5,
        "speaker": null,
        "speakerScore": 0.48147231340408325,
        "verificationScore": 0.48147231340408325,
        "verified": null,
        "role": "USER",
        "commandStatus": "EXECUTED",
        "executed": true,
        "createdDate": "2026-05-15T20:43:32.299704"
      };

      final record = UserSessionRecord.fromJson(json);

      expect(record.id, 1);
      expect(record.userId, 3);
      expect(record.transcript, ' Move backward 5 meters.');
      expect(record.action, 'MOVE');
      expect(record.direction, 'BACKWARD');
      expect(record.value, 5);
      expect(record.commandStatus, 'EXECUTED');
      expect(record.executed, true);
      expect(record.createdDate?.year, 2026);
    });
  });
}
