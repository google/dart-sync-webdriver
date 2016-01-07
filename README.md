Dart Sync WebDriver
================

[![Build Status](https://travis-ci.org/google/dart-sync-webdriver.svg?branch=master)](https://travis-ci.org/google/dart-sync-webdriver)
[![pub package](https://img.shields.io/pub/v/sync_webdriver.svg)](https://pub.dartlang.org/packages/sync_webdriver)

**NOTE:** Dart Sync WebDriver is **deprecated**. Consider switching to the async [webdriver.dart](https://github.com/google/webdriver.dart).

Installing
----------

This library depends on https://github.com/google/dart-sync-socket which uses
a native extension. After doing a pub get or upgrade, you must build the native extension
by running:
```
  # ./packages/sync_socket/../tool/build.sh
```

Projects that use Sync WebDriver should include the following in their
pubspec.yaml:

```
sync_webdriver: '^1.2.0'
```
