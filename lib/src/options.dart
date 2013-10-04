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
  void add(Cookie cookie) => _post('', { 'cookie': cookie });

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
      expiry = new DateTime
          .fromMillisecondsSinceEpoch(json['expiry']*1000, isUtc: true);
    }
    return new Cookie(
        json['name'],
        json['value'],
        path: json['path'],
        domain: json['domain'],
        secure: json['secure'],
        expiry: expiry);
  }

  Map<String, dynamic> toJson() {
    var json = {
        'name': name,
        'value': value
    };
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
}

class Timeouts extends _WebDriverBase {

  Timeouts._(driver): super(driver, 'timeouts');

  void _set(String type, Duration duration) =>
      _post('', { 'type' : type, 'ms': duration.inMilliseconds});

  /// Set the script timeout.
  void setScriptTimeout(Duration duration) => _set('script', duration);

  /// Set the implicit timeout.
  void setImplicitTimeout(Duration duration) => _set('implicit', duration);

  /// Set the page load timeout.
  void setPageLoadTimeout(Duration duration) => _set('page load', duration);

  /// Set the async script timeout.
  void setAsyncScriptTimeout(Duration duration) =>
      _post('async_script', { 'ms': duration.inMilliseconds});

  /// Set the implicit wait timeout.
  void setImplicitWaitTimeout(Duration duration) =>
      _post('implicit_wait', { 'ms': duration.inMilliseconds});
}
