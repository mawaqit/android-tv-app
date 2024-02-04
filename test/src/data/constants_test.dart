import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/src/const/constants.dart';

void main() {
  group("Environment variables tests", () {
    test('Sentry dns', () {
      expect(kSentryDns, isNot(''));
    });

    test('Mawaqit access key', () {
      expect(kApiToken, isNot(''));
    });
  });
}
