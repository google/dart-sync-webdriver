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

library webdriver_test.window;

import 'dart:math' show Point;

import 'package:unittest/unittest.dart';
import 'package:sync_webdriver/sync_webdriver.dart';
import '../test_util.dart';

void main() {

  group('Window', () {

    WebDriver driver;

    setUp(() => driver = freshDriver);

    test('size', () {
      driver.window.size = new Size(400, 600);
      var size = driver.window.size;
      expect(size, isSize);
      // TODO(DrMarcII): Switch to hasProperty matchers
      expect(size.height, 400);
      expect(size.width, 600);
    });

    test('location', () {
      driver.window.location = new Point(10, 20);
      var point = driver.window.location;
      expect(point, isPoint);
      // TODO(DrMarcII): Switch to hasProperty matchers
      expect(point.x, 10);
      expect(point.y, 20);
    });

    // fails in some cases with multiple monitors
    test('maximize', () {
      driver.window.maximize();
      var point = driver.window.location;
      expect(point, isPoint);
      // TODO(DrMarcII): Switch to hasProperty matchers
      expect(point.x, 0);
      expect(point.y, 0);
    });
  });
}
