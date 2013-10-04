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

class Touch extends _WebDriverBase{

  Touch._(driver) : super(driver, 'touch');

  /**
   * Single tap on the touch enabled device.
   */
  void click(WebElement element) => _post('click', element);

  /**
   * Finger down on the screen.
   */
  void down(Point point) => _post('down', point);

  /**
   * Finger up on the screen.
   */
  void up(Point point) => _post('up', point);

  /**
   * Finger move on the screen.
   */
  void move(Point point) => _post('move', point);

  /**
   * Scroll on the touch screen using finger based motion events.
   *
   * If start is specified, will start scrolling from that location, otherwise
   * will start scrolling from an arbitrary location.
   */
  void scroll(int xOffset, int yOffset, [WebElement start]) {
    var json = { 'xoffset': xOffset.floor(), 'yoffset': yOffset.floor()};
    if (start is WebElement) {
      json['element'] = start._elementId;
    }
    _post('scroll', json);
  }

  /**
   * Double tap on the touch screen using finger motion events.
   */
  void doubleClick(WebElement element) => _post('doubleclick', element);

  /**
   * Long press on the touch screen using finger motion events.
   */
  void longClick(WebElement element) => _post('longclick', element);

  /**
   * Flick on the touch screen using finger motion events.
   */
  void flickElement(WebElement start, int xOffset, int yOffset, int speed) =>
      _post('flick', {
        'element': start._elementId,
        'xoffset': xOffset.floor(),
        'yoffset': yOffset.floor(),
        'speed': speed.floor()
      });

  /**
   * Flick on the touch screen using finger motion events.
   */
  void flick(int xSpeed, int ySpeed) =>
      _post('flick', {
        'xspeed': xSpeed.floor(),
        'yspeed': ySpeed.floor()
      });
}
