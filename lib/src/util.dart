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

// TODO Exception management
class UnexpectedTagNameException extends FormatException {
  UnexpectedTagNameException(String expectedTagName, String actualTagName)
    : super('Element should have been "$expectedTagName" but was "$actualTagName"');
}

_setSelected(WebElement option) {
  if (!option.selected) {
    option.click();
  }
}

_unsetSelected(WebElement option) {
  if (option.selected) {
    option.click();
  }
}

String _escapeQuotes(String toEscape) {
  // Convert strings with both quotes and ticks into: foo'"bar -> concat("foo'", '"', "bar")
  if (toEscape.indexOf("\"") > -1 && toEscape.indexOf("'") > -1) {
    var quoteIsLast = false;
    if (toEscape.lastIndexOf("\"") == toEscape.length - 1) {
      quoteIsLast = true;
    }
    var substrings = toEscape.split("\"");

    var quoted = new StringBuffer("concat(");
    for (int i = 0; i < substrings.length; i++) {
      quoted.write("\"").append(substrings[i]).append("\"");
      quoted.write(((i == substrings.length - 1) ? (quoteIsLast ? ", '\"')" : ")") : ", '\"', "));
    }
    return quoted.toString();
  }

  // Escape string with just a quote into being single quoted: f"oo -> 'f"oo'
  if (toEscape.indexOf('"') > -1) {
    return "'$toEscape'";
  }

  // Otherwise return the quoted string
  return '"$toEscape"';
}

String _getLongestSubstringWithoutSpace(String value) {
  var longest = "";
  value.split(" ").forEach((item) {
    if (item.length > longest.length) {
      longest = item;
    }
  });
  return longest;
}

/**
 * Models a SELECT tag, providing helper methods to select and deselect options.
 */
class Select {
  WebElement _element;
  bool _isMulti;

  /**
   * A check is made that the given [element] is, indeed, a SELECT tag.
   * If it is not, then an [UnexpectedTagNameException] is thrown.
   */
  Select(WebElement element) {
    var tagName = element.name;

    if (null == tagName || tagName.toLowerCase() != "select") {
      throw new UnexpectedTagNameException("select", tagName);
    }

    _element = element;

    var multi = element.attributes["multiple"];

    // The atoms normalize the returned value, but check for "false"
    _isMulti = multi != null && multi != "false";
  }

  /**
   * Whether this select element support selecting multiple options at the same time?
   * This is done by checking the value of the "multiple" attribute.
   */
  bool get isMultiple => _isMulti;

  /**
   * All options belonging to this select tag
   */
  List<WebElement> get options => _element.findElements(const By.tagName("option"));

  /**
   * All selected options belonging to this select tag
   */
  List<WebElement> get allSelectedOptions => options.where((option) => option.selected);

  /**
   * The first selected option in this select tag (or the currently selected
   * option in a normal select)
   */
  // TODO Exception management
  WebElement get firstSelectedOption => options.firstWhere((option) => option.selected);

  /**
   * Select the option at the given [index].
   * This is done by examing the "index" attribute of an element, and not merely by counting.
   */
  selectByIndex(int index) {
    var match = index.toString();

    var matched = false;
    for (var option in options) {
      if (option.attributes["index"] == match) {
        _setSelected(option);
        if (!isMultiple) {
          return;
        }
        matched = true;
      }
    }

    if (!matched) {
      // TODO Exception management
      throw new NoSuchElementException(0, "Cannot locate option with index: $index");
    }
  }

  /**
   * Select all options that have a [value] matching the argument.
   * That is, when given "foo" this would select an option like:
   */
  selectByValue(String value) {
    var matched = false;
    for (var option in _findByValue(value)) {
      _setSelected(option);
      if (!isMultiple) {
        return;
      }
      matched = true;
    }

    if (!matched) {
      // TODO Exception management
      throw new NoSuchElementException(0, "Cannot locate option with value: $value");
    }
  }

  /**
   * Select all options that display [text] matching the argument.
   * That is, when given "Bar" this would select an option like:
   *
   * &lt;option value="foo"&gt;Bar&lt;/option&gt;
   */
  selectByVisibleText(String text) {
    var foundOptions = _findByVisibleText(text);

    var matched = false;
    for (var option in foundOptions) {
      _setSelected(option);
      if (!isMultiple) {
        return;
      }
      matched = true;
    }

    if (foundOptions.isEmpty && text.contains(" ")) {
      for (var option in _findByVisibleTextWithSpace(text)) {
        if (option.text == text) {
          _setSelected(option);
          if (!isMultiple) {
            return;
          }
          matched = true;
        }
      }
    }

    if (!matched) {
      // TODO Exception management
      throw new NoSuchElementException(0, "Cannot locate element with text: " + text);
    }
  }

  /**
   * Clear all selected entries.
   * This is only valid when the SELECT supports multiple selections.
   */
  deselectAll() {
    if (!isMultiple) {
      // TODO Exception management
      throw new Exception("You may only deselect all options of a multi-select");
    }

    for (var option in options) {
      _unsetSelected(option);
    }
  }

  /**
   * Deselect the option at the given [index].
   * This is done by examing the "index" attribute of an element, and not merely by counting.
   */
  deselectByIndex(int index) {
    var match = index.toString();

    for (var option in options) {
      if (option.attributes["index"] == match) {
        _unsetSelected(option);
      }
    }
  }

  /**
   * Deselect all options that have a [value] matching the argument.
   * That is, when given "foo" this would deselect an option like:
   *
   * &lt;option value="foo"&gt;Bar&lt;/option&gt;
   */
  deselectByValue(String value) {
    for (var option in _findByValue(value)) {
      _unsetSelected(option);
    }
  }

  /**
   * Deselect all options that display [text] matching the argument.
   * That is, when given "Bar" this would deselect an option like:
   *
   * &lt;option value="foo"&gt;Bar&lt;/option&gt;
   */
  deselectByVisibleText(String text) {
    var foundOptions = _findByVisibleText(text);

    for (var option in foundOptions) {
      _unsetSelected(option);
    }

    if (foundOptions.isEmpty && text.contains(" ")) {
      for (var option in _findByVisibleTextWithSpace(text)) {
        _unsetSelected(option);
      }
    }
  }

  List<WebElement> _findByValue(String value) {
    var buffer = new StringBuffer(".//option[@value = ");
    buffer.write(_escapeQuotes(value));
    buffer.write("]");
    return _element.findElements(new By.xpath(buffer.toString()));
  }

  List<WebElement> _findByVisibleText(String text) {
    var buffer = new StringBuffer(".//option[normalize-space(.) = ");
    buffer.write(_escapeQuotes(text));
    buffer.write("]");
    return _element.findElements(new By.xpath(buffer.toString()));
  }

  List<WebElement> _findByVisibleTextWithSpace(String text) {
    var candidates;
    var subStringWithoutSpace = _getLongestSubstringWithoutSpace(text);
    if (subStringWithoutSpace == "") {
      // hmm, text is either empty or contains only spaces - get all options ...
      candidates = options;
    } else {
      // get candidates via XPATH ...
      var buffer = new StringBuffer(".//option[contains(., ");
      buffer.write(_escapeQuotes(subStringWithoutSpace));
      buffer.write(")]");
      candidates = _element.findElements(new By.xpath(buffer.toString()));
    }
    return candidates;
  }
}
