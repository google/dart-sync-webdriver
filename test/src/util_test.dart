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
library webdriver_test.util;

import 'package:test/test.dart';
import 'package:sync_webdriver/sync_webdriver.dart';
import '../test_util.dart';

void main() {
  group('waitFor()', () {
    test('that returns a string', () {
      var count = 0;
      var result = waitFor(() {
        if (count == 2) return 'webdriver - Google Search';
        count++;
        return count;
      }, equals('webdriver - Google Search'));

      expect(result, equals('webdriver - Google Search'));
    });

    test('that returns null', () {
      var count = 0;
      var result = waitFor(() {
        if (count == 2) return null;
        count++;
        return count;
      }, isNull);
      expect(result, isNull);
    });

    test('that returns false', () {
      var count = 0;
      var result = waitFor(() {
        if (count == 2) return false;
        count++;
        return count;
      }, isFalse);
      expect(result, isFalse);
    });
  });

  group('waitForValue()', () {
    test('that returns a string', () {
      var count = 0;
      var result = waitForValue(() {
        if (count == 2) return 'Google';
        count++;
        return null;
      });
      expect(result, equals('Google'));
    });

    test('that returns false', () {
      var count = 0;
      var result = waitForValue(() {
        expect(count, lessThanOrEqualTo(2));
        if (count == 2) {
          count++;
          return false;
        }
        count++;
        return null;
      });
      expect(result, isFalse);
    });
  });

  group('custom Matcher', () {
    WebDriver driver;
    setUp(() {
      driver = createTestDriver();
      driver.url = testPagePath;
    });

    tearDown(() {
      driver.quit();
      driver = null;
    });

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
    WebDriver driver;
    WebElement selectSimple;
    WebElement selectMulti;

    setUp(() {
      driver = createTestDriver();
      driver.url = testPagePath;
      selectSimple = driver.findElement(const By.id('select-simple'));
      selectMulti = driver.findElement(const By.id('select-multi'));
    });

    tearDown(() {
      driver.quit();
      driver = null;
      selectSimple = null;
      selectMulti = null;
    });

    test('isMultiple', () {
      expect(new Select(selectSimple).isMultiple, false);
      expect(new Select(selectMulti).isMultiple, true);
    });

    test('selectByIndex simple', () {
      var select = new Select(selectSimple)..selectByIndex(2);
      var options = select.options;

      expect(options[0].selected, false);
      expect(options[1].selected, false);
      expect(options[2].selected, true);
      expect(options[3].selected, false);
      expect(options[2], select.firstSelectedOption);
      expect(options[2].text, "Apple");
      expect(options[2].attributes["value"], "appleValue");
      expect(select.allSelectedOptions, [options[2]]);
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
      expect(options[1].attributes["value"], "greenValue");
      expect(select.allSelectedOptions, [options[1], options[3]]);
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
      var select = new Select(selectSimple)..selectByValue("appleValue");
      var options = select.options;

      expect(options[2].selected, true);
      expect(options[2], select.firstSelectedOption);
      expect(options[2].text, "Apple");
      expect(options[2].attributes["value"], "appleValue");
      expect(select.allSelectedOptions, [options[2]]);
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
      expect(options[1].attributes["value"], "greenValue");
      expect(select.allSelectedOptions, [options[1], options[3]]);
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
      var select = new Select(selectSimple)..selectByVisibleText("Apple");
      var options = select.options;

      expect(options[2].selected, true);
      expect(options[2], select.firstSelectedOption);
      expect(options[2].text, "Apple");
      expect(options[2].attributes["value"], "appleValue");
      expect(select.allSelectedOptions, [options[2]]);
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
      expect(options[1].attributes["value"], "greenValue");
      expect(select.allSelectedOptions, [options[1], options[3]]);
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
