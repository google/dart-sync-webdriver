/*
Copyright 2013 Google Inc. All Rights Reserved.

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
library webdriver_test.options;

import 'package:sync_webdriver/sync_webdriver.dart';
import 'package:test/test.dart';

import '../test_util.dart';

void main() {
  group('Cookies', () {
    WebDriver driver;

    setUp(() {
      driver = createTestDriver();
      driver.url = 'http://www.google.com/ncr';
    });

    tearDown(() {
      driver.quit();
      driver = null;
    });

    test('add simple cookie', () {
      driver.cookies.add(new Cookie('mycookie', 'myvalue'));
      var found = false;
      for (var cookie in driver.cookies.all) {
        if (cookie.name == 'mycookie') {
          found = true;
          expect(cookie.value, 'myvalue');
          break;
        }
      }
      expect(found, isTrue);
    });

    test('add complex cookie', () {
      var date = new DateTime.utc(2099);
      driver.cookies.add(new Cookie('mycomplexcookie', 'myvalue',
          path: '/', domain: '.google.com', secure: false, expiry: date));
      var found = false;
      for (var cookie in driver.cookies.all) {
        if (cookie.name == 'mycomplexcookie') {
          found = true;
          expect(cookie.value, 'myvalue');
          expect(cookie.expiry, date);
          break;
        }
      }
      expect(found, isTrue);
    });

    test('delete cookie', () {
      driver.cookies.add(new Cookie('mycookie', 'myvalue'));
      driver.cookies.delete('mycookie');
      bool found = false;
      for (var cookie in driver.cookies.all) {
        if (cookie.name == 'mycookie') {
          found = true;
        }
      }
      expect(found, isFalse);
    });

    test('delete all cookies', () {
      driver.cookies.add(new Cookie('mycookie', 'myvalue'));
      waitFor(() => driver.cookies.all, hasLength(isPositive));
      driver.cookies.deleteAll();
      waitFor(() => driver.cookies.all, isEmpty);
    });
  });

  group('TimeOuts', () {
    WebDriver driver;

    setUp(() {
      driver = createTestDriver();
    });

    tearDown(() {
      driver.quit();
      driver = null;
    });

    test('set all timeouts', () {
      expect(driver.timeouts.scriptTimeout, isNull);
      var timeout = new Duration(seconds: 5);
      driver.timeouts.scriptTimeout = timeout;
      expect(driver.timeouts.scriptTimeout, equals(timeout));

      expect(driver.timeouts.pageLoadTimeout, isNull);
      timeout = new Duration(seconds: 10);
      driver.timeouts.pageLoadTimeout = timeout;
      expect(driver.timeouts.pageLoadTimeout, equals(timeout));

      timeout = new Duration(seconds: 2);
      driver.timeouts.implicitWaitTimeout = timeout;
      expect(driver.timeouts.implicitWaitTimeout, equals(timeout));
    });
  });
}
