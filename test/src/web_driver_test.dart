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

library webdriver_test.web_driver;

import 'package:unittest/unittest.dart';
import 'package:sync_webdriver/sync_webdriver.dart';
import '../test_util.dart';

void main() {
  group('WebDriver', () {
    WebDriver driver;

    setUp(() {
      driver = freshDriver;
      driver.url = testPagePath;
    });

    test('set url', () {
      driver.url = 'http://www.google.com';
      driver.findElement(new By.name('q'));
      driver.url = testPagePath;
      driver.findElement(new By.id('table1'));
    });

    test('get url', () {
      var url = driver.url;
      expect(url, startsWith('file:'));
      expect(url, endsWith('test_page.html'));
      driver.url = 'http://www.google.com';
      url = driver.url;
      expect(url, contains('www.google.com'));
    });

    test('findElement -- success', () {
      expect(driver.findElement(new By.tagName('tr')), isWebElement);
    });

    test('findElement -- failure', () {
      expect(() => driver.findElement(new By.id('non-existent-id')),
          throwsA(new isInstanceOf<NoSuchElementException>()));
    });

    test('findElements -- 1 found', () {
      var elements =
          driver.findElements(new By.cssSelector('input[type=text]'));
      expect(elements, hasLength(1));
      expect(elements, everyElement(isWebElement));
    });

    test('findElements -- 4 found', () {
      var elements = driver.findElements(new By.tagName('td'));
      expect(elements, hasLength(4));
      expect(elements, everyElement(isWebElement));
    });

    test('findElements -- 0 found', () {
      expect(driver.findElements(new By.id('non-existent-id')), isEmpty);
    });

    test('pageSource', () {
      expect(driver.pageSource, contains('<title>test_page</title>'));
    });

    test('close/windows', () {
      int numHandles = driver.windows.length;
      driver.findElement(new By.partialLinkText('Open copy')).click();
      expect(driver.windows.length, numHandles + 1);
      driver.close();
      expect(driver.windows.length, numHandles);
    });

    test('windows', () {
      var windows = driver.windows;
      expect(windows, hasLength(isPositive));
      expect(windows, everyElement(isWindow));
    });

    test('window', () {
      expect(driver.window, isWindow);
    });

    test('execute', () {
      WebElement button = driver.findElement(new By.tagName('button'));
      String script = '''
          arguments[1].textContent = arguments[0];
          return arguments[1];''';
      var e = driver.execute(script, ['new text', button]);
      expect(e.text, 'new text');
    });

    test('executeAsync', () {
      WebElement button = driver.findElement(new By.tagName('button'));
      String script = '''
          arguments[1].textContent = arguments[0];
          arguments[2](arguments[1]);''';
      var e = driver.executeAsync(script, ['new text', button]);
      expect(e.text, 'new text');
    });

    test('captureScreenshot', () {
      var screenshot = driver.captureScreenshot();
      expect(screenshot, hasLength(isPositive));
      expect(screenshot, everyElement(new isInstanceOf<int>()));
      expect(screenshot, everyElement(inInclusiveRange(0, 255)));
    });
  });
}
