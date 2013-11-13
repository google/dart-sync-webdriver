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

library webdriver_test.util;

import 'package:unittest/unittest.dart';
import 'package:sync_webdriver/sync_webdriver.dart';
import '../test_util.dart';

void main() {

  WebDriver driver;

  setUp(() {
    driver = freshDriver;
    driver.url = testPagePath;
  });

  group('waitFor()', () {

    test('that returns a string', () {
      driver.url = 'http://www.google.com';
      driver.findElement(new By.name('q'))
        .sendKeys('webdriver');
      driver.findElement(new By.name('btnG')).click();
      var title = waitFor(() => driver.title, equals('webdriver - Google Search'));
      expect(title, equals('webdriver - Google Search'));
    });

    test('that returns null', () {
      driver.url = 'http://www.google.com';
      var result = waitFor(() => null, isNull);
      expect(result, isNull);
    });

    test('that returns false', () {
      driver.url = 'http://www.google.com';
      driver.findElement(new By.name('q'))
        .sendKeys('webdriver');
      driver.findElement(new By.name('btnG')).click();
      var result = waitFor(() => driver.findElement(const By.name('btnI')).displayed, isFalse);
      expect(result, isFalse);
    });
  });

  group('waitForValue()', () {

    test('that returns a string', () {
      driver.url = 'http://www.google.com';
      var title = waitForValue(() => driver.title);
      expect(title, equals('Google'));
    });

    test('that returns temporarily returns null', () {
      const NOT_NULL = 'not-null';
      int called = 0;
      nullUntilSecondInvocation() {
        if (called > 0) {
          return NOT_NULL;
        }
        ++called;
        return null;
      }

      var result = waitForValue(() => nullUntilSecondInvocation());
      expect(result, NOT_NULL);
    });

    test('that returns false', () {
      driver.url = 'http://www.google.com';
      var result = waitForValue(() => driver.findElement(const By.name('btnG')).displayed);
      expect(result, isFalse);
    });
  });

  group('custom Matcher', () {

    test('isDisplayed', () {
      var body = driver.findElement(const By.tagName('body'));
      expect(body, isDisplayed);
    });

    test('isNotDisplayed', () {
      var div = driver.findElement(const By.tagName('div'));
      expect(div, isNotDisplayed);
    });

    test('isEnabled', () {
      var body = driver.findElement(const By.tagName('body'));
      expect(body, isEnabled);
    });

    test('isNotEnabled', () {
      var input = driver.findElement(const By.cssSelector('input[type=password]'));
      expect(input, isNotEnabled);
    });

    test('hasText', () {
      var button = driver.findElement(new By.tagName('button'));
      expect(button, hasText('button'));
      expect(button, hasText(equalsIgnoringCase('BUTTON')));
    });
  });
}
