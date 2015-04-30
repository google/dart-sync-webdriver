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
library webdriver_test.alert;

import 'package:test/test.dart';
import 'package:sync_webdriver/sync_webdriver.dart';
import '../test_util.dart';

void main() {
  group('Alert', () {
    WebDriver driver;
    WebElement button;
    WebElement output;

    setUp(() {
      driver = createTestDriver();
      driver.url = testPagePath;
      button = driver.findElement(new By.tagName('button'));
      output = driver.findElement(new By.id('settable'));
    });

    tearDown(() {
      driver.quit();
      driver = null;
      button = null;
      output = null;
    });

    test('no alert', () {
      expect(() => driver.switchTo.alert,
          throwsA(new isInstanceOf<NoAlertOpenException>()));
    });

    test('text', () {
      button.click();
      var alert = driver.switchTo.alert;
      expect(alert.text, 'button clicked');
      alert.dismiss();
    });

    test('accept', () {
      button.click();
      var alert = driver.switchTo.alert;
      alert.accept();
      expect(output.text, startsWith('accepted'));
    });

    test('dismiss', () {
      button.click();
      var alert = driver.switchTo.alert;
      alert.dismiss();
      expect(output.text, startsWith('dismissed'));
    });

    test('sendKeys', () {
      button.click();
      var alert = driver.switchTo.alert;
      alert.sendKeys('some keys');
      alert.accept();
      expect(output.text, endsWith('some keys'));
    });
  });
}
