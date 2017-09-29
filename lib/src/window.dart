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

class Window extends _WebDriverBase {
  final String _handle;

  Window._(WebDriver driver, String handle)
      : this._handle = handle,
        super(driver, 'window/$handle');

  /// The size of this window.
  Size get size => new Size.fromJson(_get('size'));

  /// The location of this window.
  Point<int> get location => _jsonToPoint(_get('position'));

  /// Maximize this window.
  void maximize() => _post('maximize');

  /// Set this window size.
  set size(Size size) => _post('size', size);

  /// Set this window location.
  set location(Point point) => _post('position', _pointToJson(point));

  String toJson() => _handle;

  @override
  bool operator ==(other) =>
      driver == other.driver && _handle == other._handle;

  @override
  int get hashCode => _handle.hashCode >> 3 + driver.hashCode;
}
