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

  Iterable<LogEntry> get(String logType) =>
      _post('', {'type': logType}).map((entry) => new LogEntry.fromMap(entry));
}

class LogEntry {
  final String message;
  final int timestamp;
  final String level;

  const LogEntry(this.message, this.timestamp, this.level);

  LogEntry.fromMap(Map map)
      : this(map['message'], map['timestamp'], map['level']);
}

class LogType {
  static const String BROWSER = 'browser';
  static const String CLIENT = 'client';
  static const String DRIVER = 'driver';
  static const String PERFORMANCE = 'performance';
  static const String PROFILER = 'profiler';
  static const String SERVER = 'server';
}

class LogLevel {
  static const String OFF = 'OFF';
  static const String SEVERE = 'SEVERE';
  static const String WARNING = 'WARNING';
  static const String INFO = 'INFO';
  static const String DEBUG = 'DEBUG';
  static const String ALL = 'ALL';
}
