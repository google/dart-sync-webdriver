Dart Sync WebDriver
================

Synchronous WebDriver and PageLoader libraries.

Installing
----------

This library depends on https://github.com/google/dart-sync-socket which uses
a native extension that prevents it being host on http://pub.dartlang.org. To
use download the latest release of this package and
https://github.com/google/dart-sync-socket. Build the native extension for
Dart Sync Socket, and set the path for sync_socket in Sync WebDriver's
pubspec.yaml to point the location on disk for Dart Sync Socket.

Projects that use Sync WebDriver should include the following in their
pubspec.yaml:

```
sync_webdriver:
  path: <path to Sync WebDriver>
```
