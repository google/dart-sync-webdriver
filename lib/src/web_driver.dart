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

@deprecated

/// Use [CommandEvent] instead.
typedef void CommandListener(String method, String endpoint, params);

class WebDriver extends SearchContext {
  static final Uri DEFAULT_URI = new Uri.http('127.0.0.1:4444', '/wd/hub');
  static final HttpClientSync _client = new HttpClientSync();

  final Uri uri;
  final Map<String, Object> capabilities;

  JsonCodec _jsonDecoder;
  Timeouts _timeouts;

  final StreamController<CommandEvent> _onCommand =
      new StreamController.broadcast(sync: true);
  Stream<CommandEvent> get onCommand => _onCommand.stream;

  factory WebDriver(
      {Uri uri: null,
      Map<String, String> required: null,
      Map<String, String> desired: const <String, String>{}}) {
    if (uri == null) {
      uri = DEFAULT_URI;
    }
    var request = _client
        .postUrl(new Uri.http(uri.authority, path.join(uri.path, 'session')));
    var jsonParams = {"desiredCapabilities": desired};

    if (required != null) {
      jsonParams["requiredCapabilities"] = required;
    }

    request.headers.contentType = _CONTENT_TYPE_JSON;
    request.write(JSON.encode(jsonParams));

    var resp = request.close();

    var sessionUri;
    var capabilities = const {};
    switch (resp.statusCode) {
      case HttpStatus.SEE_OTHER:
      case HttpStatus.MOVED_TEMPORARILY:
      case HttpStatus.MOVED_PERMANENTLY:
        sessionUri = Uri.parse(resp.headers.value(HttpHeaders.LOCATION));
        if (sessionUri.authority == null || sessionUri.authority.isEmpty) {
          sessionUri = new Uri.http(uri.authority, sessionUri.path);
        }
        break;
      case HttpStatus.OK:
        var jsonResp = _parseBody(resp);
        if (jsonResp is! Map || jsonResp['status'] != 0) {
          throw new WebDriverException(
              httpStatusCode: resp.statusCode,
              httpReasonPhrase: resp.reasonPhrase,
              jsonResp: jsonResp);
        }

        sessionUri = _sessionUri(uri, jsonResp['sessionId']);
        capabilities = new UnmodifiableMapView(jsonResp['value']);
        break;
      default:
        throw new WebDriverException(
            httpStatusCode: resp.statusCode,
            httpReasonPhrase: resp.reasonPhrase,
            jsonResp: _parseBody(resp));
    }

    return new WebDriver._(sessionUri, capabilities);
  }

  factory WebDriver.fromExistingSession(String sessionId, {Uri uri}) {
    if (uri == null) {
      uri = DEFAULT_URI;
    }

    var request = _client.getUrl(_sessionUri(uri, sessionId));
    var resp = request.close();
    var jsonResp = _parseBody(resp);

    if (jsonResp is! Map || jsonResp['status'] != 0) {
      throw new WebDriverException(
          httpStatusCode: resp.statusCode,
          httpReasonPhrase: resp.reasonPhrase,
          jsonResp: jsonResp);
    }

    var capabilities = new UnmodifiableMapView<String, Object>(jsonResp['value']);
    return new WebDriver._(_sessionUri(uri, sessionId), capabilities);
  }

  static Uri _sessionUri(Uri uri, String sessionId) =>
      new Uri.http(uri.authority, path.join(uri.path, "session", sessionId));

  WebDriver._(this.uri, this.capabilities) {
    _jsonDecoder = new JsonCodec.withReviver(_reviver);
    _timeouts = new Timeouts._(this);
  }

  @override
  WebDriver get driver => this;

  set url(String url) => post('url', {'url': url});

  String get url => get('url');

  String get title => get('title');

  String get pageSource => get('source');

  void close() {
    delete('window');
  }

  void quit() {
    delete('');
  }

  Iterable<Window> get windows =>
      get('window_handles').map((handle) => new Window._(this, handle));

  Window get window => new Window._(this, get('window_handle'));

  WebElement get activeElement => get('element/active');

  TargetLocator get switchTo => new TargetLocator._(this);

  Navigation get navigate => new Navigation._(this);

  Mouse get mouse => new Mouse._(this);

  Keyboard get keyboard => new Keyboard._(this);

  Touch get touch => new Touch._(this);

  Cookies get cookies => new Cookies._(this);

  Logs get logs => new Logs._(this);

  Timeouts get timeouts => _timeouts;

  /**
   * Inject a snippet of JavaScript into the page for execution in the context
   * of the currently selected frame. The executed script is assumed to be
   * asynchronous and must signal that is done by invoking the provided
   * callback, which is always provided as the final argument to the function.
   * The value to this callback will be returned to the client.
   *
   * Asynchronous script commands may not span page loads. If an unload event
   * is fired while waiting for a script result, an error will be thrown.
   *
   * The script argument defines the script to execute in the form of a
   * function body. The function will be invoked with the provided args array
   * and the values may be accessed via the arguments object in the order
   * specified. The final argument will always be a callback function that must
   * be invoked to signal that the script has finished.
   *
   * Arguments may be any JSON-able object. WebElements will be converted to
   * the corresponding DOM element. Likewise, any DOM Elements in the script
   * result will be converted to WebElements.
   */
  dynamic executeAsync(String script, List args) =>
      post('execute_async', {'script': script, 'args': args});

  /**
   * Inject a snippet of JavaScript into the page for execution in the context
   * of the currently selected frame. The executed script is assumed to be
   * synchronous and the result of evaluating the script is returned.
   *
   * The script argument defines the script to execute in the form of a
   * function body. The value returned by that function will be returned to the
   * client. The function will be invoked with the provided args array and the
   * values may be accessed via the arguments object in the order specified.
   *
   * Arguments may be any JSON-able object. WebElements will be converted to
   * the corresponding DOM element. Likewise, any DOM Elements in the script
   * result will be converted to WebElements.
   */
  dynamic execute(String script, List args) =>
      post('execute', {'script': script, 'args': args});

  List<int> captureScreenshot() =>
      new UnmodifiableListView(BASE64.decode(captureScreenshotAsBase64()));

  String captureScreenshotAsBase64() => get('screenshot');

  _reviver(dynamic key, dynamic value) {
    if (value is Map && value.containsKey('ELEMENT')) {
      return new WebElement._(this, value['ELEMENT']);
    }
    return value;
  }

  @override
  _post(String command, [params]) => post(command, params);

  post(String command, [params]) {
    var startTime = new DateTime.now();
    var response;
    var exception;
    try {
      var path = _processCommand(command);
      var request = _client.postUrl(new Uri.http(uri.authority, path));
      if (params != null) {
        request.headers.contentType = _CONTENT_TYPE_JSON;
        request.write(JSON.encode(params));
      }
      response = _processResponse(request.close());
      return response;
    } catch (e) {
      exception = e;
      rethrow;
    } finally {
      _onCommand.add(new CommandEvent(
          method: 'POST',
          endpoint: command,
          params: params != null ? JSON.encode(params) : null,
          startTime: startTime,
          endTime: new DateTime.now(),
          result: response != null ? JSON.encode(response) : null,
          exception: exception != null ? exception.toString() : null,
          stackTrace: new Trace.current(1)));
    }
  }

  get(String command) {
    var startTime = new DateTime.now();
    var response;
    var exception;
    try {
      var path = _processCommand(command);
      var request = _client.getUrl(new Uri.http(uri.authority, path));
      response = _processResponse(request.close());
      return response;
    } catch (e) {
      exception = e;
      rethrow;
    } finally {
      if (command.contains('screenshot') && response != null) {
        response = 'screenshot';
      }
      _onCommand.add(new CommandEvent(
          method: 'GET',
          endpoint: command,
          startTime: startTime,
          endTime: new DateTime.now(),
          result: response != null ? JSON.encode(response) : null,
          exception: exception != null ? exception.toString() : null,
          stackTrace: new Trace.current(1)));
    }
  }

  delete(String command) {
    var startTime = new DateTime.now();
    var response;
    var exception;
    try {
      var path = _processCommand(command);
      var request = _client.deleteUrl(new Uri.http(uri.authority, path));
      response = _processResponse(request.close());
      return response;
    } catch (e) {
      exception = e;
      rethrow;
    } finally {
      _onCommand.add(new CommandEvent(
          method: 'DELETE',
          endpoint: command,
          startTime: startTime,
          endTime: new DateTime.now(),
          result: response != null ? JSON.encode(response) : null,
          exception: exception != null ? exception.toString() : null,
          stackTrace: new Trace.current(1)));
    }
  }

  String _processCommand(String command) {
    return path.join(uri.path, command);
  }

  _processResponse(HttpClientResponseSync resp) {
    if (resp.statusCode == HttpStatus.NO_CONTENT) {
      return null;
    }
    var jsonBody = _parseBody(resp, _jsonDecoder);

    if (resp.statusCode != HttpStatus.OK ||
        jsonBody is! Map ||
        jsonBody['status'] != 0) {
      throw new WebDriverException(
          httpStatusCode: resp.statusCode,
          httpReasonPhrase: resp.reasonPhrase,
          jsonResp: jsonBody);
    }

    return jsonBody['value'];
  }

  @override
  String toString() => '{WebDriver $uri}';
}

final _NUL_REGEXP = new RegExp('\u{0}');

_parseBody(HttpClientResponseSync resp, [JsonCodec jsonDecoder = JSON]) {
  if (resp.contentLength == 0) {
    return null;
  }
  if (resp.body == null) {
    return null;
  }
  String body = resp.body.replaceAll(_NUL_REGEXP, '').trim();

  if (body.isEmpty) {
    return null;
  }

  if (resp.headers.contentType.mimeType == _CONTENT_TYPE_JSON.mimeType) {
    return jsonDecoder.decode(body);
  }

  return body;
}
