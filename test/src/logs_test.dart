/*
Copyright 2015 Google Inc. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

@TestOn('vm')
library webdriver_test.logs;

import 'package:sync_webdriver/sync_webdriver.dart';
import 'package:test/test.dart';

import '../test_util.dart';

void main() {
  group('Logs', () {
    WebDriver driver;

    setUp(() {
      driver = createTestDriver(
          additionalCapabilities: {
        Capabilities.LOGGING_PREFS: {LogType.PERFORMANCE: LogLevel.INFO}
      });
      driver.url = testPagePath;
    });

    tearDown(() {
      driver.quit();
      driver = null;
    });

    test('get logs', () {
      Iterable<LogEntry> logs = driver.logs.get(LogType.PERFORMANCE);
      expect(logs.length, greaterThan(0));
      logs.forEach((entry) {
        expect(entry.level, equals(LogLevel.INFO));
      });
    });
  });
}
