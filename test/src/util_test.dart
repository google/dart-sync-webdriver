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
      driver.url = 'http://www.google.com/ncr';
      driver.findElement(new By.name('q'))
        .sendKeys('webdriver');
      driver.findElement(new By.name('btnG')).click();
      var title =
          waitFor(() => driver.title, equals('webdriver - Google Search'));
      expect(title, equals('webdriver - Google Search'));
    });

    test('that returns null', () {
      driver.url = 'http://www.google.com/ncr';
      var result = waitFor(() => null, isNull);
      expect(result, isNull);
    });

    test('that returns false', () {
      driver.url = 'http://www.google.com/ncr';
      driver.findElement(new By.name('q'))
        .sendKeys('webdriver');
      driver.findElement(new By.name('btnG')).click();
      var result = waitFor(
          () => driver.findElement(const By.name('btnI')).displayed, isFalse);
      expect(result, isFalse);
    });
  });

  group('waitForValue()', () {

    test('that returns a string', () {
      driver.url = 'http://www.google.com/ncr';
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
      driver.url = 'http://www.google.com/ncr';
      var result = waitForValue
          (() => driver.findElement(const By.name('btnG')).displayed);
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
      var input =
          driver.findElement(const By.cssSelector('input[type=password]'));
      expect(input, isNotEnabled);
    });

    test('hasText', () {
      var button = driver.findElement(const By.tagName('button'));
      expect(button, hasText('button'));
      expect(button, hasText(equalsIgnoringCase('BUTTON')));
    });
  });

  group('Select class', () {

    WebElement selectSimple;
    WebElement selectMulti;

    setUp(() {
      driver = freshDriver;
      driver.url = testPagePath;
      selectSimple = driver.findElement(const By.id('select-simple'));
      selectMulti = driver.findElement(const By.id('select-multi'));
    });

    test('isMultiple', () {
      expect(new Select(selectSimple).isMultiple, false);
      expect(new Select(selectMulti).isMultiple, true);
    });

    test('selectByIndex simple', () {
      var select = new Select(selectSimple)
        ..selectByIndex(2);
      var options = select.options;

      expect(options[0].selected, false);
      expect(options[1].selected, false);
      expect(options[2].selected, true);
      expect(options[3].selected, false);
      expect(options[2], select.firstSelectedOption);
      expect(options[2].text, "Apple");
      expect(options[2].value, "appleValue");
      expect(select.allSelectedOptions, [ options[2] ]);
      expect(select.value, "appleValue");
    });

    test('[de]selectByIndex multiple', () {
      var select = new Select(selectMulti)
        ..selectByIndex(1)
        ..selectByIndex(3);
      var options = select.options;

      expect(options[0].selected, false);
      expect(options[1].selected, true);
      expect(options[2].selected, false);
      expect(options[3].selected, true);
      expect(options[1], select.firstSelectedOption);
      expect(options[1].text, "Green");
      expect(options[1].value, "greenValue");
      expect(select.allSelectedOptions, [ options[1], options[3] ]);
      expect(select.value, "greenValue");

      select.deselectAll();
      expect(options[0].selected, false);
      expect(options[1].selected, false);
      expect(options[2].selected, false);
      expect(options[3].selected, false);

      select
        ..selectByIndex(1)
        ..selectByIndex(3)
        ..deselectByIndex(3);
      expect(options[0].selected, false);
      expect(options[1].selected, true);
      expect(options[2].selected, false);
      expect(options[3].selected, false);
    });

    test('selectByValue simple', () {
      var select = new Select(selectSimple)
        ..selectByValue("appleValue");
      var options = select.options;

      expect(options[2].selected, true);
      expect(options[2], select.firstSelectedOption);
      expect(options[2].text, "Apple");
      expect(options[2].value, "appleValue");
      expect(select.allSelectedOptions, [ options[2] ]);
      expect(select.value, "appleValue");
    });

    test('[de]selectByValue multiple', () {
      var select = new Select(selectMulti)
        ..selectByValue("greenValue")
        ..selectByValue("yellowValue");
      var options = select.options;

      expect(options[1].selected, true);
      expect(options[1], select.firstSelectedOption);
      expect(options[1].text, "Green");
      expect(options[1].value, "greenValue");
      expect(select.allSelectedOptions, [ options[1], options[3] ]);
      expect(select.value, "greenValue");

      select.deselectAll();
      expect(options[0].selected, false);
      expect(options[1].selected, false);
      expect(options[2].selected, false);
      expect(options[3].selected, false);

      select
        ..selectByValue("greenValue")
        ..selectByValue("yellowValue")
        ..deselectByValue("yellowValue");
      expect(options[0].selected, false);
      expect(options[1].selected, true);
      expect(options[2].selected, false);
      expect(options[3].selected, false);
    });

    test('selectByVisibleText simple', () {
      var select = new Select(selectSimple)
        ..selectByVisibleText("Apple");
      var options = select.options;

      expect(options[2].selected, true);
      expect(options[2], select.firstSelectedOption);
      expect(options[2].text, "Apple");
      expect(options[2].value, "appleValue");
      expect(select.allSelectedOptions, [ options[2] ]);
      expect(select.value, "appleValue");
    });

    test('[de]selectByVisibleText multiple', () {
      var select = new Select(selectMulti)
        ..selectByVisibleText("Green")
        ..selectByVisibleText("Yellow");
      var options = select.options;

      expect(options[1].selected, true);
      expect(options[1], select.firstSelectedOption);
      expect(options[1].text, "Green");
      expect(options[1].value, "greenValue");
      expect(select.allSelectedOptions, [ options[1], options[3] ]);
      expect(select.value, "greenValue");

      select.deselectAll();
      expect(options[0].selected, false);
      expect(options[1].selected, false);
      expect(options[2].selected, false);
      expect(options[3].selected, false);

      select
        ..selectByVisibleText("Green")
        ..selectByVisibleText("Yellow")
        ..deselectByVisibleText("Yellow");
      expect(options[0].selected, false);
      expect(options[1].selected, true);
      expect(options[2].selected, false);
      expect(options[3].selected, false);
    });
  });
}
