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

library webdriver_test.mouse;

import 'package:unittest/unittest.dart';
import 'package:sync_webdriver/sync_webdriver.dart';
import '../test_util.dart';

void main() {
  group('Mouse', () {
    WebDriver driver;
    WebElement button;

    setUp(() {
      driver = createTestDriver();
      driver.url = testPagePath;
      button = driver.findElement(new By.tagName('button'));
    });

    tearDown(() {
      driver.quit();
      driver = null;
      button = null;
    });

    test('moveTo element/click', () {
      driver.mouse
        ..moveTo(element: button)
        ..click();
      driver.switchTo.alert.dismiss();
    });

    test('moveTo coordinates/click', () {
      var pos = button.location;
      driver.mouse
        ..moveTo(xOffset: pos.x + 5, yOffset: pos.y + 5)
        ..click();
      driver.switchTo.alert.dismiss();
    });

    test('moveTo element coordinates/click', () {
      driver.mouse
        ..moveTo(element: button, xOffset: 5, yOffset: 5)
        ..click();
      driver.switchTo.alert.dismiss();
    });

    // TODO(DrMarcII): Better up/down tests
    test('down/up', () {
      driver.mouse
        ..moveTo(element: button)
        ..down()
        ..up();
      driver.switchTo.alert.dismiss();
    });

    // TODO(DrMarcII): Better double click test
    test('doubleClick', () {
      driver.mouse
        ..moveTo(element: button)
        ..doubleClick();
      driver.switchTo.alert.dismiss();
    });
  });
}
