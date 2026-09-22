import 'package:flutter_test/flutter_test.dart';
import 'package:younis_app/app/config/app_environment.dart';

void main() {
  group('AppEnvironment tests', () {
    test('parses explicit names correctly', () {
      expect(AppEnvironment.fromName('production'), AppEnvironment.production);
      expect(AppEnvironment.fromName('prod'), AppEnvironment.production);
      expect(AppEnvironment.fromName('staging'), AppEnvironment.staging);
      expect(AppEnvironment.fromName('stg'), AppEnvironment.staging);
      expect(AppEnvironment.fromName('development'), AppEnvironment.development);
      expect(AppEnvironment.fromName('dev'), AppEnvironment.development);
    });

    test('defaults safely for unknown or empty input', () {
      expect(AppEnvironment.fromName(''), AppEnvironment.development);
      expect(AppEnvironment.fromName(null), AppEnvironment.development);
      expect(AppEnvironment.fromName('unknown'), AppEnvironment.development);
    });
  });
}
