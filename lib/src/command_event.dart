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

/// Object for holding the details of a command event.
class CommandEvent {
  /// HTTP method for the command.
  final String method;
  /// HTTP endpoint for the command.
  final String endpoint;
  /// String representation of the params sent for the command.
  final String params;
  /// When the command started execution.
  final DateTime startTime;
  /// When the command ended execution.
  final DateTime endTime;
  /// String representation of the returned response for the command.
  /// If the command failed, this will be null.
  final String result;
  /// String representation of the exception thrown when the command failed.
  /// If the command succeeded, this will be null.
  final String exception;
  /// Stack trace at the point of the execution of the WebDriver command.
  final Trace stackTrace;

  CommandEvent({this.method, this.endpoint, this.params, this.startTime,
      this.endTime, this.result, this.exception, this.stackTrace});
}
