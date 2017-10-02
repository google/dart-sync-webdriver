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

class WebElement extends _WebDriverBase with SearchContext {
  final String id;

  // The following three fields identify the provenance of this element
  SearchContext _context;
  Finder _finder;
  int _index;

  WebElement._(WebDriver driver, String elementId)
      : id = elementId,
        super(driver, 'element/$elementId');

  /// Click on this element.
  void click() {
    _post('click');
  }

  /// Submit this element if it is part of a form.
  void submit() => _post('submit');

  /// Send [keysToSend] (a [String] or [List<String>]) to this element.
  void sendKeys(dynamic keysToSend) {
    if (keysToSend is String) {
      keysToSend = [keysToSend];
    }
    _post('value', {'value': keysToSend as List<String>});
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
  bool equals(WebElement other) => this == other || _get('equals/${other.id}');

  Map<String, String> toJson() => new Map<String, String>()..[_ELEMENT] = id;

  @override
  bool operator ==(Object other) =>
      other is WebElement && driver == other.driver && id == other.id;

  @override
  int get hashCode => id.hashCode >> 3 + driver.hashCode;

  void _updateProvenance(SearchContext context, Finder finder,
      [int index = -1]) {
    this._context = context;
    this._finder = finder;
    this._index = index;
  }

  @override
  String toString() {
    StringBuffer result = new StringBuffer('{WebElement ');
    result.write(id);
    if (_context != null && _finder != null) {
      result..write(' ')..write(_context);
      if (_index >= 0) {
        result.write('.findElements(');
      } else {
        result.write('.findElement(');
      }
      result.write(_finder);
      if (_index >= 0) {
        result..write(')[')..write(_index)..write(']}');
      } else {
        result.write(')}');
      }
    }
    return result.toString();
  }
}
