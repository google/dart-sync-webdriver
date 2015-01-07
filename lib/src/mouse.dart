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

class Mouse extends _WebDriverBase {
  static const int LEFT = 0;
  static const int MIDDLE = 1;
  static const int RIGHT = 2;

  Mouse._(driver) : super(driver, '');

  /// Click any mouse button (at the coordinates set by the last moveTo).
  void click([int button]) {
    var json = {};
    if (button is num) {
      json['button'] = button.clamp(0, 2).floor();
    }
    _post('click', json);
  }

  /**
   * Click and hold any mouse button (at the coordinates set by the last
   * moveTo command).
   */
  void down([int button]) {
    var json = {};
    if (button is num) {
      json['button'] = button.clamp(0, 2).floor();
    }
    _post('buttondown', json);
  }

  /**
   * Releases the mouse button previously held (where the mouse is currently
   * at).
   */
  void up([int button]) {
    var json = {};
    if (button is num) {
      json['button'] = button.clamp(0, 2).floor();
    }
    _post('buttonup', json);
  }

  /// Double-clicks at the current mouse coordinates (set by moveTo).
  void doubleClick() => _post('doubleclick');

  /**
   * Move the mouse.
   *
   * If [element] is specified and [xOffset] and [yOffset] are not, will move
   * the mouse to the center of the [element].
   *
   * If [xOffset] and [yOffset] are specified, will move the mouse that distance
   * from its current location.
   *
   * If all three are specified, will move the mouse to the offset relative to
   * the top-left corner of the [element].
   *
   * All other combinations of parameters are illegal.
   */
  void moveTo({WebElement element, int xOffset, int yOffset}) {
    var json = {};
    if (element is WebElement) {
      json['element'] = element._elementId;
    }
    if (xOffset is num && yOffset is num) {
      json['xoffset'] = xOffset.floor();
      json['yoffset'] = yOffset.floor();
    }
    _post('moveto', json);
  }
}
