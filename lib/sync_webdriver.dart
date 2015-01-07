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

library sync.webdriver;

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show Point;
import 'dart:mirrors';

import 'package:crypto/crypto.dart';
import 'package:matcher/matcher.dart';
import 'package:sync_socket/sync_socket.dart';

part 'src/alert.dart';
part 'src/capabilities.dart';
part 'src/common.dart';
part 'src/error.dart';
part 'src/keyboard.dart';
part 'src/keys.dart';
part 'src/mouse.dart';
part 'src/navigation.dart';
part 'src/options.dart';
part 'src/target_locator.dart';
part 'src/touch.dart';
part 'src/util.dart';
part 'src/web_driver.dart';
part 'src/web_element.dart';
part 'src/window.dart';
