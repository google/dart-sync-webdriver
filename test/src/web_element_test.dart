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

library webdriver_test.web_element;

import 'package:unittest/unittest.dart';
import 'package:sync_webdriver/sync_webdriver.dart';
import '../test_util.dart';

void main() {

  group('WebElement', () {

    WebDriver driver;
    WebElement table;
    WebElement button;
    WebElement form;
    WebElement textInput;
    WebElement checkbox;
    WebElement disabled;
    WebElement invisible;

    setUp(() {
      driver = freshDriver;
      driver.url = testPagePath;
      table = driver.findElement(new By.tagName('table'));
      button = driver.findElement(new By.tagName('button'));
      form = driver.findElement(new By.tagName('form'));
      textInput = driver.findElement(new By.cssSelector('input[type=text]'));
      checkbox = driver.findElement(new By.cssSelector('input[type=checkbox]'));
      disabled = driver.findElement(new By.cssSelector('input[type=password]'));
      invisible = driver.findElement(new By.tagName('div'));
    });

    test('click', () {
      button.click();
      driver.switchTo.alert.accept();
    });

    test('submit', () {
      form.submit();
      var alert = driver.switchTo.alert;
      expect(alert.text, 'form submitted');
      alert.accept();
    });

    test('sendKeys', () {
      textInput.sendKeys('some keys');
      expect(textInput.attributes['value'], 'some keys');
    });

    test('clear', () {
      textInput.sendKeys('some keys');
      textInput.clear();
      expect(textInput.attributes['value'], '');
    });

    test('enabled', () {
      expect(table.enabled, isTrue);
      expect(button.enabled, isTrue);
      expect(form.enabled, isTrue);
      expect(textInput.enabled, isTrue);
      expect(checkbox.enabled, isTrue);
      expect(disabled.enabled, isFalse);
    });

    test('displayed', () {
      expect(table.displayed, isTrue);
      expect(button.displayed, isTrue);
      expect(form.displayed, isTrue);
      expect(textInput.displayed, isTrue);
      expect(checkbox.displayed, isTrue);
      expect(disabled.displayed, isTrue);
      expect(invisible.displayed, isFalse);
    });

    test('location -- table', () {
      var location = table.location;
      expect(location, isPoint);
      // TODO(DrMarcII): Switch to hasProperty matchers
      expect(location.x, isNonNegative);
      expect(location.y, isNonNegative);
    });

    test('location -- invisible', () {
      var location = invisible.location;
      expect(location, isPoint);
      // TODO(DrMarcII): Switch to hasProperty matchers
      expect(location.x, 0);
      expect(location.y, 0);
    });

    test('size -- table', () {
      var size = table.size;
      expect(size, isSize);
      // TODO(DrMarcII): Switch to hasProperty matchers
      expect(size.width, isNonNegative);
      expect(size.height, isNonNegative);
    });

    test('size -- invisible', () {
      var size = invisible.size;
      expect(size, isSize);
      // TODO(DrMarcII): I thought these should be 0
      // TODO(DrMarcII): Switch to hasProperty matchers
      expect(size.width, isNonNegative);
      expect(size.height, isNonNegative);
    });

    test('name', () {
      expect(table.name, 'table');
      expect(button.name, 'button');
      expect(form.name, 'form');
      expect(textInput.name, 'input');
    });

    test('text', () {
      expect(table.text, 'r1c1 r1c2\nr2c1 r2c2');
      expect(button.text, 'button');
      expect(invisible.text, '');
    });

    test('findElement -- success', () {
      expect(table.findElement(new By.tagName('tr')), isWebElement);
    });

    test('findElement -- failure', () {
      expect(() => button.findElement(new By.tagName('tr')),
          throwsA(new isInstanceOf<NoSuchElementException>()));
    });

    test('findElements -- 1 found', () {
      var elements = form.findElements(new By.cssSelector('input[type=text]'));
      expect(elements, hasLength(1));
      expect(elements, everyElement(isWebElement));
    });

    test('findElements -- 4 found', () {
      var elements = table.findElements(new By.tagName('td'));
      expect(elements, hasLength(4));
      expect(elements, everyElement(isWebElement));
    });

    test('findElements -- 0 found', () {
      expect(form.findElements(new By.tagName('td')), isEmpty);
    });

    test('attributes', () {
      expect(table.attributes['id'], 'table1');
      expect(table.attributes['non-standard'],
          'a non standard attr');
      expect(table.attributes['disabled'], isNull);
      expect(disabled.attributes['disabled'], 'true');
    });

    test('cssProperties', () {
      expect(invisible.cssProperties['display'], 'none');
      expect(invisible.cssProperties['background-color'],
          'rgba(255, 0, 0, 1)');
      expect(invisible.cssProperties['direction'], 'ltr');
    });

    test('equals', () {
      expect(invisible.equals(disabled), isFalse);
      var element = driver.findElement(new By.cssSelector('table'));
      expect(element.equals(table), isTrue);
    });
  });
}
