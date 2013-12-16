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

final ContentType _CONTENT_TYPE_JSON =
    new ContentType("application", "json", charset: "utf-8");

class WebElement extends _WebDriverBase implements SearchContext {

  final String _elementId;

  WebElement._(WebDriver driver, String elementId)
    : super(driver, 'element/$elementId'),
      _elementId = elementId;

  /// Click on this element.
  void click() {
    _post('click');
  }

  /// Submit this element if it is part of a form.
  void submit() => _post('submit');

  /// Send [keysToSend] (a [String] or [List<String>]) to this element.
  void sendKeys(dynamic keysToSend) {
    if (keysToSend is String) {
      keysToSend = [ keysToSend ];
    }
    _post('value', { 'value' : keysToSend as List<String>});
  }

  /// Clear the content of a text element.
  void clear() => _post('clear');

  /// Is this radio button/checkbox/option selected?
  bool get selected => _get('selected');

  /// Is this form element enabled?
  bool get enabled => _get('enabled');

  /// Is this element visible in the page?
  bool get displayed => _get('displayed');

  /// The location within the document of this element.
  Point<int> get location => _jsonToPoint(_get('location'));

  /// The size of this element.
  Size get size => new Size.fromJson(_get('size'));

  /// The tag name for this element.
  String get name => _get('name');

  /// Visible text within this element.
  String get text => _get('text');

  /// The value for this element
  String get value => _get('value');

  /**
   * Find an element nested within this element.
   *
   * Throws [NoSuchElementException] if matching element is not found.
   */
  @override
  WebElement findElement(Finder finder) {
    if (finder is By) {
      return _post('element', finder);
    } else {
      return finder.findElement(this);
    }
  }

  /// Find multiple elements nested within this element.
  @override
  List<WebElement> findElements(Finder finder) {
    if (finder is By) {
      return new UnmodifiableListView(_post('elements', finder));
    } else {
      return new UnmodifiableListView(finder.findElements(this));
    }
  }

  /**
   * Access to the HTML attributes of this tag.
   *
   * TODO(DrMarcII): consider special handling of boolean attributes.
   */
  Attributes get attributes => new Attributes._(driver, _prefix, 'attribute');

  /**
   * Access to the cssProperties of this element.
   *
   * TODO(DrMarcII): consider special handling of color and possibly other
   *                 properties.
   */
  Attributes get cssProperties => new Attributes._(driver, _prefix, 'css');

  /**
   * Does this element represent the same element as another element?
   * Not the same as ==
   */
  bool equals(WebElement other) =>
      this == other || _get('equals/${other._elementId}');

  Map<String, String> toJson() =>
      new Map<String, String>()..[_ELEMENT] = _elementId;

  @override
  bool operator ==(Object other) => other is WebElement &&
      driver == other.driver &&
      _elementId == other._elementId;

  @override
  int get hashCode => _elementId.hashCode >> 3 + driver.hashCode;

  @override
  String toString() => toJson().toString();
}
