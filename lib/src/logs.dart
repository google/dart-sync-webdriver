/*
Copyright 2015 Google Inc. All Rights Reserved.

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

class Logs extends _WebDriverBase {
  Logs._(driver) : super(driver, 'log');

  List get(String logType) => _post('', {'type' : logType});
}

class LogType {
  static final String BROWSER = 'browser';
  static final String CLIENT = 'client';
  static final String DRIVER = 'driver';
  static final String PERFORMANCE = 'performance';
  static final String PROFILER = 'profiler';
  static final String SERVER = 'server';
}

class LogLevel {
  static final String OFF = 'OFF';
  static final String SEVERE = 'SEVERE';
  static final String WARNING = 'WARNING';
  static final String INFO = 'INFO';
  static final String DEBUG = 'DEBUG';
  static final String ALL = 'ALL';
}
