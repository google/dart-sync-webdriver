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

const String _ELEMENT = 'ELEMENT';

/**
 * Simple class to provide access to indexed properties such as WebElement
 * attributes or css styles.
 */
class Attributes extends _WebDriverBase {

  Attributes._(driver, prefix, command)
    : super(driver, '$prefix/$command');

  String operator [](String name) => _get(name);
}

class Size {
  final num height;
  final num width;

  const Size(this.height, this.width);

  Size.fromJson(Map json) : this(json['height'], json['width']);

  Map<String, num> toJson() => {
    'height': height,
    'width': width
  };

  @override
  bool operator ==(Object other) => other is Size &&
      height == (other as Size).height &&
      width == (other as Size).width;

  @override
  int get hashCode => width.hashCode << 3 + height.hashCode;

  @override
  String toString() => toJson().toString();
}

class Point {
  final num x;
  final num y;

  const Point(this.x, this.y);

  Point.fromJson(Map json) : this(json['x'], json['y']);

  Map<String, num> toJson() => {
    'x': x,
    'y': y
  };

  @override
  bool operator ==(Object other) => other is Point &&
      x == (other as Point).x &&
      y == (other as Point).y;

  @override
  int get hashCode => x.hashCode << 3 + y.hashCode;

  @override
  String toString() => toJson().toString();
}

abstract class SearchContext {
  WebDriver get driver;

  /// Searches for multiple elements within the context.
  List<WebElement> findElements(Finder by);

  /**
   * Searchs for an element within the context.
   *
   * Throws [WebDriverError] no such element exception if no matching element is
   * found.
   */
  WebElement findElement(Finder by);
}

abstract class _WebDriverBase {
  final String _prefix;
  final WebDriver driver;

  _WebDriverBase(this.driver, this._prefix);

  dynamic _post(String command, [param]) =>
      driver._post(_command(command), param);

  dynamic _get(String command) =>
      driver._get(_command(command));

  dynamic _delete(String command) =>
      driver._delete(_command(command));

  String _command(String command) {
    if (command == null || command.isEmpty) {
      return _prefix;
    } else if (_prefix == null || _prefix.isEmpty) {
      return command;
    } else if (command.startsWith('/')) {
      return '$_prefix$command';
    } else
      return '$_prefix/$command';
  }
}

abstract class Finder {
  const Finder();

  WebElement findElement(SearchContext context);

  List<WebElement> findElements(SearchContext context);
}

class By implements Finder {
  final String _using;
  final String _value;

  const By._(this._using, this._value);

  /// Returns an element whose ID attribute matches the search value.
  const By.id(String id) : this._('id', id);

  /// Returns an element matching an XPath expression.
  const By.xpath(String xpath) : this._('xpath', xpath);

  /// Returns an anchor element whose visible text matches the search value.
  const By.linkText(String linkText) : this._('link text', linkText);

  /**
   * Returns an anchor element whose visible text partially matches the search
   * value.
   */
  const By.partialLinkText(String partialLinkText) :
      this._('partial link text', partialLinkText);

  /// Returns an element whose NAME attribute matches the search value.
  const By.name(String name) : this._('name', name);

  /// Returns an element whose tag name matches the search value.
  const By.tagName(String tagName) : this._('tag name', tagName);

  /**
   * Returns an element whose class name contains the search value; compound
   * class names are not permitted
   */
  const By.className(String className) : this._('class name', className);

  /// Returns an element matching a CSS selector.
  const By.cssSelector(String cssSelector) :
      this._('css selector', cssSelector);

  Map<String, String> toJson() => { 'using': _using, 'value': _value};

  @override
  bool operator ==(Object other) => other is By &&
      _using == (other as By)._using &&
      _value == (other as By)._value;

  @override
  int get hashCode => _using.hashCode << 3 + _value.hashCode;

  @override
  WebElement findElement(SearchContext context) => context.findElement(this);

  @override
  List<WebElement> findElements(SearchContext context) =>
      context.findElements(this);
}
