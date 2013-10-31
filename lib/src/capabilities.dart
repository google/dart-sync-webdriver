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

class Capabilities {
  static const String BROWSER_NAME = "browserName";
  static const String PLATFORM = "platform";
  static const String SUPPORTS_JAVASCRIPT = "javascriptEnabled";
  static const String TAKES_SCREENSHOT = "takesScreenshot";
  static const String VERSION = "version";
  static const String SUPPORTS_ALERTS = "handlesAlerts";
  static const String SUPPORTS_SQL_DATABASE = "databaseEnabled";
  static const String SUPPORTS_LOCATION_CONTEXT = "locationContextEnabled";
  static const String SUPPORTS_APPLICATION_CACHE = "applicationCacheEnabled";
  static const String SUPPORTS_BROWSER_CONNECTION = "browserConnectionEnabled";
  static const String SUPPORTS_FINDING_BY_CSS = "cssSelectorsEnabled";
  static const String PROXY = "proxy";
  static const String SUPPORTS_WEB_STORAGE = "webStorageEnabled";
  static const String ROTATABLE = "rotatable";
  static const String ACCEPT_SSL_CERTS = "acceptSslCerts";
  static const String HAS_NATIVE_EVENTS = "nativeEvents";
  static const String UNEXPECTED_ALERT_BEHAVIOUR = "unexpectedAlertBehaviour";
  static const String LOGGING_PREFS = "loggingPrefs";
  static const String ENABLE_PROFILING_CAPABILITY =
      "webdriver.logging.profiler.enabled";
  static const String QUIET_EXCEPTIONS = "webdriver.remote.quietExceptions";
  static const String CHROME_OPTIONS = "chromeOptions";

  static Map<String, dynamic> get chrome => empty
      ..[BROWSER_NAME] = Browser.CHROME
      ..[VERSION] = ''
      ..[PLATFORM] = Platform.ANY
      ..[CHROME_OPTIONS] = new ChromeOptions();


  static Map<String, dynamic> get firefox => empty
      ..[BROWSER_NAME] = Browser.FIREFOX
      ..[VERSION] = ''
      ..[PLATFORM] = Platform.ANY;

  static Map<String, dynamic> get android => empty
      ..[BROWSER_NAME] = Browser.ANDROID
      ..[VERSION] = ''
      ..[PLATFORM] = Platform.ANDROID;

  static Map<String, dynamic> get empty => new Map<String, dynamic>()
      // quiet exceptions because the Sync HTTP Client is not robust enough
      // to handle screenshots
      ..[QUIET_EXCEPTIONS] = true;
}

class Browser {
  static const String FIREFOX = "firefox";
  static const String FIREFOX_2 = "firefox2";
  static const String FIREFOX_3 = "firefox3";
  static const String FIREFOX_PROXY = "firefoxproxy";
  static const String FIREFOX_CHROME = "firefoxchrome";
  static const String GOOGLECHROME = "googlechrome";
  static const String SAFARI = "safari";
  static const String OPERA = "opera";
  static const String IEXPLORE= "iexplore";
  static const String IEXPLORE_PROXY= "iexploreproxy";
  static const String SAFARI_PROXY = "safariproxy";
  static const String CHROME = "chrome";
  static const String KONQUEROR = "konqueror";
  static const String MOCK = "mock";
  static const String IE_HTA="iehta";
  static const String ANDROID = "android";
  static const String HTMLUNIT = "htmlunit";
  static const String IE = "internet explorer";
  static const String IPHONE = "iPhone";
  static const String IPAD = "iPad";
  static const String PHANTOMJS = "phantomjs";
}

class Platform {
  static const String ANY = "ANY";
  static const String ANDROID = "ANDROID";
}

class ChromeOptions {
  /**
   * The path to the Chrome executable. This path should exist on the
   * machine which will launch Chrome. The path should either be absolute or
   * relative to the location of running ChromeDriver server.
   */
  String binary;

  /**
   * Chrome extensions to install on browser startup. Each [File] should
   * specify a packed Chrome extension (CRX file) that exists locally.
   */
  final List<File> extensions = <File>[];

  /**
   * Additional command line arguments to be used when starting Chrome.
   *
   * Each argument may contain an option "--" prefix: "--foo" or "foo".
   * Arguments with an associated value should be delimitted with an "=":
   * "foo=bar".
   */
  final List<String> arguments = <String>[];

  /**
   * New ChromeDriver options not yet exposed through the [ChromeOptions] API.
   *
   * All values must be convertible to JSON.
   */
  final Map<String, dynamic> experimentalOptions = <String, dynamic>{};

  Map<String, dynamic> toJson() {
    var json = new Map<String, dynamic>.from(experimentalOptions);
    if (binary != null) {
      json['binary'] = binary;
    }
    if (arguments.isNotEmpty) {
      json['args'] = new List<String>.from(arguments, growable: false);
    }
    if (extensions.isNotEmpty) {
      json['extensions'] =
          extensions.map(_encodeExtension).toList(growable: false);
    }

    return json;
  }

  String _encodeExtension(File file) =>
      CryptoUtils.bytesToBase64(file.readAsBytesSync());
}
