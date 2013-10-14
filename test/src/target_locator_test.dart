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

library webdriver_test.target_locator;

import 'package:unittest/unittest.dart';
import 'package:sync_webdriver/sync_webdriver.dart';
import '../test_util.dart';

/**
 * Tests for switchTo.frame(). switchTo.window() and switchTo.alert are tested
 * in other classes.
 */
void main() {

  group('TargetLocator', () {

    WebDriver driver;

    setUp(() {
      driver = freshDriver;
      driver.url = testPagePath;
    });

    test('frame index', () {
      driver.switchTo.frame(0);
      expect(driver.pageSource, contains('this is a frame'));
    });

    test('frame name', () {
      driver.switchTo.frame('frame');
      expect(driver.pageSource, contains('this is a frame'));
    });

    test('frame element', () {
      var frame = driver.findElement(new By.name('frame'));
      driver.switchTo.frame(frame);
      expect(driver.pageSource, contains('this is a frame'));
    });

    test('root frame', () {
      driver.switchTo.frame(0);
      expect(driver.pageSource, contains('this is a frame'));
      driver.switchTo.frame();
      expect(() => driver.findElement(new By.tagName('button')),
          returnsNormally);
    });

    test('window object', () {
      driver.findElement(new By.partialLinkText('Open copy')).click();
      for(var window in driver.windows) {
        driver.switchTo.window(window);
        expect(driver.window, window);
      }
    });
  });
}
