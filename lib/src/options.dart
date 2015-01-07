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

class Cookies extends _WebDriverBase {
  Cookies._(driver) : super(driver, 'cookie');

  /// Set a cookie.
  void add(Cookie cookie) => _post('', {'cookie': cookie});

  /// Delete the cookie with the given [name].
  void delete(String name) => _delete(name);

  /// Delete all cookies visible to the current page.
  void deleteAll() => _delete('');

  /// Retrieve all cookies visible to the current page.
  Iterable<Cookie> get all =>
      _get('').map((cookie) => new Cookie.fromJson(cookie));
}

class Cookie {
  /// The name of the cookie.
  final String name;
  /// The cookie value.
  final String value;
  /// (Optional) The cookie path.
  final String path;
  /// (Optional) The domain the cookie is visible to.
  final String domain;
  /// (Optional) Whether the cookie is a secure cookie.
  final bool secure;
  /// (Optional) When the cookie expires.
  final DateTime expiry;

  const Cookie(this.name, this.value,
      {this.path, this.domain, this.secure, this.expiry});

  factory Cookie.fromJson(Map<String, dynamic> json) {
    var expiry;
    if (json['expiry'] is num) {
      expiry = new DateTime.fromMillisecondsSinceEpoch(
          (json['expiry'] * 1000).round(), isUtc: true);
    }
    return new Cookie(json['name'], json['value'],
        path: json['path'],
        domain: json['domain'],
        secure: json['secure'],
        expiry: expiry);
  }

  Map<String, dynamic> toJson() {
    var json = {'name': name, 'value': value};
    if (path is String) {
      json['path'] = path;
    }
    if (domain is String) {
      json['domain'] = domain;
    }
    if (secure is bool) {
      json['secure'] = secure;
    }
    if (expiry is DateTime) {
      json['expiry'] = (expiry.millisecondsSinceEpoch / 1000).ceil();
    }
    return json;
  }

  @override
  String toString() => toJson().toString();
}

class Timeouts extends _WebDriverBase {
  Duration _scriptTimeout;
  Duration _implicitWaitTimeout;
  Duration _pageLoadTimeout;

  Timeouts._(driver) : super(driver, 'timeouts');

  _set(String type, Duration duration) =>
      _post('', {'type': type, 'ms': duration.inMilliseconds});

  /// Get the script timeout.
  Duration get scriptTimeout => _scriptTimeout;
  /// Set the script timeout.
  set scriptTimeout(Duration duration) {
    _set('script', duration);
    return _scriptTimeout = duration;
  }

  /// Get the implicit timeout.
  Duration get implicitWaitTimeout => _implicitWaitTimeout;
  /// Set the implicit timeout.
  set implicitWaitTimeout(Duration duration) {
    _set('implicit', duration);
    return _implicitWaitTimeout = duration;
  }

  /// Get the page load timeout.
  Duration get pageLoadTimeout => _pageLoadTimeout;
  /// Set the page load timeout.
  set pageLoadTimeout(Duration duration) {
    _set('page load', duration);
    return _pageLoadTimeout = duration;
  }
}
