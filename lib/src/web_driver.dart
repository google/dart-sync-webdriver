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

class WebDriver implements SearchContext {
  static final Uri DEFAULT_URI = new Uri.http('127.0.0.1:4444', '/wd/hub');
  static final HttpClientSync _client = new HttpClientSync();

  final Uri _uri;
  final Map<String, Object> capabilities;

  JsonCodec _jsonDecoder;
  Timeouts _timeouts;

  factory WebDriver({
      Uri uri: null,
      Map<String, String> required: null,
      Map<String, String> desired: const <String, String>{}}) {

    if (uri == null) {
      uri = DEFAULT_URI;
    }
    var request =
        _client.postUrl(new Uri.http(uri.authority, '${uri.path}/session'));
    var jsonParams = { "desiredCapabilities": desired };

    if (required != null) {
      jsonParams["requiredCapabilities"] = required;
    }

    request.write(JSON.encode(jsonParams));

    var resp = request.close();

    var sessionUri;
    var capabilities = const {};
    switch (resp.statusCode) {
      case HttpStatus.SEE_OTHER:
      case HttpStatus.MOVED_TEMPORARILY:
        sessionUri = Uri.parse(resp.headers.value(HttpHeaders.LOCATION));
        if (sessionUri.authority == null || sessionUri.authority.isEmpty) {
          sessionUri = new Uri.http(uri.authority, sessionUri.path);
        }
        break;
      case HttpStatus.OK:
        var jsonResp = _parseBody(resp);

        if (jsonResp == null || jsonResp['status'] != 0) {
          throw new WebDriverError(
              httpStatusCode: resp.statusCode,
              httpReasonPhrase: resp.reasonPhrase,
              jsonResp: jsonResp);
        }

        sessionUri = new Uri.http(uri.authority,
            '${uri.path}/session/${jsonResp['sessionId']}');
        capabilities = new UnmodifiableMapView(jsonResp['value']);
        break;
      default:
        throw new WebDriverError(
            httpStatusCode: resp.statusCode,
            httpReasonPhrase: resp.reasonPhrase,
            jsonResp: _parseBody(resp));
    }

    return new WebDriver._(sessionUri, capabilities);
  }

  WebDriver._(this._uri, this.capabilities) {
    _jsonDecoder = new JsonCodec.withReviver(_reviver);
  }

  @override
  WebDriver get driver => this;

  set url(String url) => _post('url', {'url': url});

  String get url => _get('url');

  String get title => _get('title');

  @override
  WebElement findElement(Finder finder) {
    if (finder is By) {
      return _post('element', finder);
    } else {
      return finder.findElement(this);
    }
  }

  @override
  List<WebElement> findElements(Finder finder) {
    if (finder is By) {
      return new UnmodifiableListView<WebElement>(_post('elements', finder));
    } else {
      return new UnmodifiableListView<WebElement>(finder.findElements(this));
    }
  }

  String get pageSource => _get('source');

  void close() => _delete('window');

  void quit() => _delete('');

  Iterable<Window> get windows => _get('window_handles')
      .map((handle) => new Window._(this, handle));

  Window get window => new Window._(this, _get('window_handle'));

  WebElement get activeElement => _get('element/active');

  TargetLocator get switchTo => new TargetLocator._(this);

  Navigation get navigate => new Navigation._(this);

  Mouse get mouse => new Mouse._(this);

  Keyboard get keyboard => new Keyboard._(this);

  Touch get touch => new Touch._(this);

  Cookies get cookies => new Cookies._(this);

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
      _post('execute_async', {
        'script': script,
        'args': args
      });

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
      _post('execute', {
        'script': script,
        'args': args
      });

  List<int> captureScreenshot() => new UnmodifiableListView(
      CryptoUtils.base64StringToBytes(_get('screenshot')));

  _reviver(dynamic key, dynamic value) {
    if (value is Map && value.containsKey('ELEMENT')) {
      return new WebElement._(this, value['ELEMENT']);
    }
    return value;
  }

  _post(String command, params) {
    var path = _processCommand(command);
    var request =  _client.postUrl(new Uri.http(_uri.authority, path));
    if (params != null) {
      request.headers.contentType = _CONTENT_TYPE_JSON;
      request.write(JSON.encode(params));
    }
    return _processResponse(request.close());
  }

  _get(String command) {
    var path = _processCommand(command);
    var request = _client.getUrl(new Uri.http(_uri.authority, path));
    return _processResponse(request.close());
  }

  _delete(String command) {
    var path = _processCommand(command);
    var request = _client.deleteUrl(new Uri.http(_uri.authority, path));
    return _processResponse(request.close());
  }

  String _processCommand(String command) {
    StringBuffer path = new StringBuffer(_uri.path);
    if (!command.isEmpty && !command.startsWith('/')) {
      path.write('/');
    }
    path.write(command);
    return path.toString();
  }

  _processResponse(HttpClientResponseSync resp) {
    if (resp.statusCode == HttpStatus.NO_CONTENT) {
      return null;
    }
    var jsonBody = _parseBody(resp, _jsonDecoder);

    if (resp.statusCode != HttpStatus.OK
        || jsonBody == null
        || jsonBody['status'] != 0) {
      throw new WebDriverError(
          httpStatusCode: resp.statusCode,
          httpReasonPhrase: resp.reasonPhrase,
          jsonResp: jsonBody);
    }

    return jsonBody['value'];
  }
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
