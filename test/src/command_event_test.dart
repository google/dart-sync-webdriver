/*
Copyright 2015 Google Inc. All Rights Reserved.

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
library webdriver_test.command_event;

import 'dart:async';

import 'package:stack_trace/stack_trace.dart';
import 'package:sync_webdriver/sync_webdriver.dart';
import 'package:test/test.dart';

import '../test_util.dart';

void main() {
  group('CommandListener', () {
    WebDriver driver;
    List<CommandEvent> commands = [];
    StreamSubscription<CommandEvent> subscription;

    setUp(() {
      driver = createTestDriver();
      driver.url = testPagePath;
      subscription = driver.onCommand.listen((evt) {
        commands.add(evt);
      });
    });

    tearDown(() {
      subscription.cancel();
      subscription = null;
      commands.clear();
      driver.quit();
      driver = null;
    });

    test('listens to commands on driver', () {
      driver.findElements(const By.id('an-id'));
      driver.captureScreenshot();

      expect(commands, hasLength(2));
      _checkCommand(commands[0], 'POST', 'elements', isNotNull);
      _checkCommand(commands[1], 'GET', 'screenshot', isNull);
    });

    test('listens to commands on element', () {
      WebElement el = driver.findElement(const By.id('table1'));
      el.name;
      el.displayed;
      el.findElements(const By.tagName('tr'));

      expect(commands, hasLength(4));
      _checkCommand(commands[0], 'POST', 'element', isNotNull);
      _checkCommand(commands[1], 'GET', matches('element/.+/name'), isNull);
      _checkCommand(
          commands[2], 'GET', matches('element/.+/displayed'), isNull);
      _checkCommand(
          commands[3], 'POST', matches('element/.+/elements'), isNotNull);
    });

    test('listens to commands on timeouts', () {
      driver.timeouts.implicitWaitTimeout = new Duration(seconds: 1);
      driver.timeouts.implicitWaitTimeout = new Duration();

      expect(commands, hasLength(2));
      _checkCommand(commands[0], 'POST', 'timeouts', isNotNull, isNull);
      _checkCommand(commands[0], 'POST', 'timeouts', isNotNull, isNull);
    });

    test('fires multiple listeners', () {
      var localCommands = [];
      var localSubscription = driver.onCommand.listen((evt) {
        localCommands.add(evt);
      });
      driver.findElements(const By.id('an-id'));
      driver.captureScreenshot();

      expect(commands, hasLength(2));
      _checkCommand(commands[0], 'POST', 'elements', isNotNull);
      _checkCommand(commands[1], 'GET', 'screenshot', isNull);
      expect(localCommands, hasLength(2));
      _checkCommand(localCommands[0], 'POST', 'elements', isNotNull);
      _checkCommand(localCommands[1], 'GET', 'screenshot', isNull);
      localSubscription.cancel();
    });

    test('errors are propagated', () {
      try {
        driver.findElement(new By.id('non-existant'));
      } catch (e) {}
      _checkCommand(
          commands[0], 'POST', 'element', isNotNull, isNull, isNotNull);
    });
  });
}

_checkCommand(CommandEvent log, method, command, params,
    [response, exception]) {
  if (response == null) {
    response = isNotNull;
  }
  if (exception == null) {
    exception = isNull;
  }
  expect(log.method, method);
  expect(log.endpoint, command);
  expect(log.params, params);
  expect(
      log.endTime,
      predicate(log.startTime.isBefore,
          'event endTime is not after event startTime'));
  expect(log.result, response);
  expect(log.exception, exception);

  var trace = new Trace.current(2).frames.map((f) => f.toString()).toList();
  expect(
      log.stackTrace.frames
          .map((f) => f.toString())
          .skipWhile((f) => f != trace[0])
          .toList(),
      trace);
}
