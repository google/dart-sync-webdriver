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

part of sync.webdriver;

const _DEFAULT_WAIT = const Duration(seconds: 4);
const _INTERVAL = const Duration(milliseconds: 100);

/**
 * Waits for [condition] to be evaluated successfully, and returns
 * that value.
 *
 * A successful evaluation is when the value returned by [condition]
 * is any value other than [null].
 *
 * Any exceptions raised during the evauluation of [condition] are
 * caught and treated as an unsuccessful evaluation.
 */
waitForValue(condition(),
    {Duration timeout: _DEFAULT_WAIT,
     Duration interval: _INTERVAL,
     onError(Object error)}) {
  return waitFor(
      condition, isNotNull, timeout: timeout, interval: interval);
}

/**
 * Waits for [condition] to be evaluated successfully, and returns
 * that value.
 *
 * A successful evaluation is when the value returned by [condition]
 * has a value that satisfies the [matcher].
 *
 * Any exceptions raised during the evauluation of [condition] are
 * caught and treated as an unsuccessful evaluation.
 */
waitFor(condition(), Matcher matcher,
    {Duration timeout: _DEFAULT_WAIT,
     Duration interval: _INTERVAL,
     onError(Object error)}) {
  conditionWithExpect() {
    var value = condition();
    expect(value, matcher);
    return value;
  }
  return _waitFor(conditionWithExpect, timeout, interval, onError);
}

_waitFor(condition(), Duration timeout, Duration interval,
         onError(Object error)) {
  var endTime = new DateTime.now().add(timeout);

  var result;
  while (true) {
    try {
      return condition();
    } catch (e) {
      if (onError != null) {
        onError(e);
      }
      result = e;
    }
    if (endTime.isBefore(new DateTime.now())) {
      break;
    }
    sleep(interval);
  }

  throw new StateError(
      'Condition timeout after $timeout.  It evaluated to $result');
}

final Matcher isEnabled = wrapMatcher((WebElement e) => e.enabled);

final Matcher isNotEnabled = isNot(isEnabled);

final Matcher isDisplayed = wrapMatcher((WebElement e) => e.displayed);

final Matcher isNotDisplayed = isNot(isDisplayed);

final Matcher isSelected = wrapMatcher((WebElement e) => e.selected);

final Matcher isNotSelected = isNot(isSelected);

Matcher hasText(matcher) => new _HasText(wrapMatcher(matcher));

class _HasText extends Matcher {
  final Matcher _matcher;
  const _HasText(this._matcher);

  bool matches(item, Map matchState) =>
      item is WebElement && _matcher.matches(item.text, matchState);

  Description describe(Description description) =>
    description.add('a WebElement with text of ')
        .addDescriptionOf(_matcher);

  Description describeMismatch(item, Description mismatchDescription,
                               Map matchState, bool verbose) {
    return mismatchDescription.add('has text of ')
        .addDescriptionOf(item.text);
  }
}
