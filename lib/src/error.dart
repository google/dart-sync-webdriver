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

abstract class WebDriverError {
  /**
   * Either the status value returned in the JSON response (preferred) or the
   * HTTP status code.
   */
  final int statusCode;

  /**
   * A message describing the error.
   */
  final String message;

  factory WebDriverError({
      int httpStatusCode,
      String httpReasonPhrase,
      dynamic jsonResp}) {
    if (jsonResp is Map) {
      var status = jsonResp['status'];
      var message = jsonResp['value']['message'];

      switch(status) {
        case 0:
          throw new StateError('Not a WebDriverError Status: 0 Message: $message');
        case 6: // NoSuchDriver
          return new NoSuchDriverError(status, message);
        case 7: // NoSuchElement
          return new NoSuchElementError(status, message);
        case 8: // NoSuchFrame
          return new NoSuchFrameError(status, message);
        case 9: // UnknownCommand
          return new UnknownCommandError(status, message);
        case 10: // StaleElementReferenceException
          return new StaleElementReferenceError(status, message);
        case 11: // ElementNotVisible
          return new ElementNotVisibleError(status, message);
        case 12: // InvalidElementState
          return new  InvalidElementStateError(status, message);
        case 15: // ElementIsNotSelectable
          return new ElementIsNotSelectableError(status, message);
        case 17: // JavaScriptError
          return new JavaScriptError(status, message);
        case 19: // XPathLookupError
          return new XPathLookupError(status, message);
        case 21: // Timeout
          return new TimeoutError(status, message);
        case 23: // NoSuchWindow
          return new NoSuchWindowError(status, message);
        case 24: // InvalidCookieDomain
          return new InvalidCookieDomainError(status, message);
        case 25: // UnableToSetCookie
          return new UnableToSetCookieError(status, message);
        case 26: // UnexpectedAlertOpen
          return new UnexpectedAlertOpenError(status, message);
        case 27: // NoAlertOpenError
          return new NoAlertOpenError(status, message);
        case 29: // InvalidElementCoordinates
          return new InvalidElementCoordinatesError(status, message);
        case 30: // IMENotAvailable
          return new IMENotAvailableError(status, message);
        case 31: // IMEEngineActivationFailed
          return new IMEEngineActivationFailedError(status, message);
        case 32: // InvalidSelector
          return new InvalidSelectorError(status, message);
        case 33: // SessionNotCreatedException
          return new SessionNotCreatedError(status, message);
        case 34: // MoveTargetOutOfBounds
          return new MoveTargetOutOfBoundsError(status, message);
        case 13: // UnknownError
        default: // new error?
          return new UnknownError(status, message);
      }
    }
    if (jsonResp != null) {
      return new InvalidRequestError(httpStatusCode, jsonResp);
    }
    return new InvalidRequestError(httpStatusCode, httpReasonPhrase);
  }

  const WebDriverError._(this.statusCode, this.message);

  String toString() => '$runtimeType ($statusCode): $message';
}

class InvalidRequestError extends WebDriverError {
  InvalidRequestError(statusCode, message) : super._(statusCode, message);
}

class UnknownError extends WebDriverError {
  UnknownError(statusCode, message) : super._(statusCode, message);
}

class NoSuchDriverError extends WebDriverError {
  NoSuchDriverError(statusCode, message) : super._(statusCode, message);
}

class NoSuchElementError extends WebDriverError {
  NoSuchElementError(statusCode, message) : super._(statusCode, message);
}

class NoSuchFrameError extends WebDriverError {
  NoSuchFrameError(statusCode, message) : super._(statusCode, message);
}

class UnknownCommandError extends WebDriverError {
  UnknownCommandError(statusCode, message) : super._(statusCode, message);
}

class StaleElementReferenceError extends WebDriverError {
  StaleElementReferenceError(statusCode, message)
      : super._(statusCode, message);
}

class ElementNotVisibleError extends WebDriverError {
  ElementNotVisibleError(statusCode, message) : super._(statusCode, message);
}

class InvalidElementStateError extends WebDriverError {
  InvalidElementStateError(statusCode, message) : super._(statusCode, message);
}

class ElementIsNotSelectableError extends WebDriverError {
  ElementIsNotSelectableError(statusCode, message)
      : super._(statusCode, message);
}

class JavaScriptError extends WebDriverError {
  JavaScriptError(statusCode, message) : super._(statusCode, message);
}

class XPathLookupError extends WebDriverError {
  XPathLookupError(statusCode, message) : super._(statusCode, message);
}

class TimeoutError extends WebDriverError {
  TimeoutError(statusCode, message) : super._(statusCode, message);
}

class NoSuchWindowError extends WebDriverError {
  NoSuchWindowError(statusCode, message) : super._(statusCode, message);
}

class InvalidCookieDomainError extends WebDriverError {
  InvalidCookieDomainError(statusCode, message) : super._(statusCode, message);
}

class UnableToSetCookieError extends WebDriverError {
  UnableToSetCookieError(statusCode, message) : super._(statusCode, message);
}

class UnexpectedAlertOpenError extends WebDriverError {
  UnexpectedAlertOpenError(statusCode, message) : super._(statusCode, message);
}

class NoAlertOpenError extends WebDriverError {
  NoAlertOpenError(statusCode, message) : super._(statusCode, message);
}

class InvalidElementCoordinatesError extends WebDriverError {
  InvalidElementCoordinatesError(statusCode, message)
      : super._(statusCode, message);
}

class IMENotAvailableError extends WebDriverError {
  IMENotAvailableError(statusCode, message) : super._(statusCode, message);
}

class IMEEngineActivationFailedError extends WebDriverError {
  IMEEngineActivationFailedError(statusCode, message)
      : super._(statusCode, message);
}

class InvalidSelectorError extends WebDriverError {
  InvalidSelectorError(statusCode, message) : super._(statusCode, message);
}

class SessionNotCreatedError extends WebDriverError {
  SessionNotCreatedError(statusCode, message) : super._(statusCode, message);
}

class MoveTargetOutOfBoundsError extends WebDriverError {
  MoveTargetOutOfBoundsError(statusCode, message)
      : super._(statusCode, message);
}
