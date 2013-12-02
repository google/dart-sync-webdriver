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

part of sync.pageloader;

class Returns {
  final Type type;

  const Returns(this.type);
}

class ReturnsList extends Returns {

  const ReturnsList(Type type) : super(type);
}

/// Filters element based on visibility.
class WithState extends ElementFilter implements HasFilterFinderOptions {

  final bool _displayed;

  const WithState._(this._displayed);

  /// Match any element as long as it present in the DOM.
  const WithState.present() : this._(null);

  /// Match only elements that are visible (the default behavior in most cases).
  const WithState.visible() : this._(true);

  /// Match only element that are present but invisible.
  const WithState.invisible() : this._(false);

  @override
  List<FilterFinderOption> get options =>
      const [ FilterFinderOption.DISABLE_IMPLICIT_DISPLAY_FILTERING ];

  @override
  bool keep(WebElement element) {
    if (_displayed != null) {
      return element.displayed == _displayed;
    }
    return true;
  }
}

/**
 * Normally if an element is not found, an exception is thrown.  This makes
 * it difficult to test for the absence of something in the DOM.  To allow an
 * element to be absent from the DOM, annotate it with this.
 */
const Optional = const _Optional();

class _Optional {
  const _Optional();
}

/**
 * Matches the root [WebElement] being used for constructing the current page
 * object.
 */
const Root = const _Root();

class _Root implements Finder, HasFilterFinderOptions {
  const _Root();

  @override
  WebElement findElement(SearchContext context) {
    if (context is WebElement) {
      return context;
    } else {
      return context.findElement(const By.xpath('/*'));
    }
  }

  @override
  List<WebElement> findElements(SearchContext context) {
    if (context is WebElement) {
      return [ context ];
    } else {
      return context.findElements(const By.xpath('/*'));
    }
  }

  @override
  List<FilterFinderOption> get options =>
      const [ FilterFinderOption.DISABLE_IMPLICIT_DISPLAY_FILTERING ];
}


/// Keeps only [WebElement]s that have the given attribute with the given value.
class WithAttribute extends ElementFilter {

  final String name;
  final String value;

  const WithAttribute(this.name, this.value);

  @override
  bool keep(WebElement element) => element.attributes[name] == value;
}

typedef ScriptExecutor(String script, List args);

abstract class _ByScript implements Finder {

  final String _js;
  final _arg;

  const _ByScript(this._js, this._arg);

  WebElement findElement(SearchContext context) {
    List<WebElement> results = findElements(context);
    if (results.isEmpty) {
      throw new NoSuchElementException(-1,
          'An element could not be located on the page using the given search '
          'parameters.');
    }
    return results[0];
  }

  List<WebElement> findElements(SearchContext context) {
    var listArg;
    if (_arg is List) {
      listArg = new List.from(_arg);
    } else if (_arg != null){
      listArg = [_arg];
    } else {
      listArg = [];
    }

    if (context is WebElement) {
      listArg.add(context);
    } else {
      listArg.add(null);
    }

    var result = executor(context)(_js, listArg);

    if (result is WebElement) {
      return new UnmodifiableListView<WebElement>([result]);
    }

    if (result is List) {
      result.forEach((element) {
        if (element is! WebElement) {
          throw new StateError('Script returned non-WebElement');
        }
      });
      return new UnmodifiableListView<WebElement>(result);
    }

    throw new StateError('Script returned non-WebElement');
  }

  ScriptExecutor executor(SearchContext context);
}

/// Finds [WebElement]s using a JavaScript script and [WebDriver.execute()].
class ByJs extends _ByScript {

  /**
   * Creates a locator that finds an element with the given script.
   *
   * If [arg] is provided it will be passed to the script as arguments as
   * follows:
   *   [arg] is a [List] of length n: will be used as the first n-arguments
   *   [arg] is not a [List]: will be used as the first argument
   *
   * In either case, the arguments will be handled as specified in
   * [WebDriver.execute()] (must be JSON-able types; [WebElement]s are
   * translated to the corresponding js DOM Elements automatically).
   */
  const ByJs(String js, [arg]) : super(js, arg);

  /**
   * If [context] is a [WebElement] it will be passed as the last argument to
   * the script.
   */
  @override
  ScriptExecutor executor(SearchContext context) => context.driver.execute;
}

/**
 * Finds [WebElement]s using a JavaScript script and [WebDriver.executeAsync()].
 */
class ByAsyncJs extends _ByScript {

  /**
   * Creates a locator that finds an element with the given script.
   *
   * If [arg] is provided it will be passed to the script as arguments as
   * follows:
   *   [arg] is a [List] of length n: will be used as the first n-arguments
   *   [arg] is not a [List]: will be used as the first argument
   *
   * In either case, the arguments will be handled as specified in
   * [WebDriver.execute()] (must be JSON-able types; [WebElement]s are
   * translated to the corresponding js DOM Elements automatically).
   */
  const ByAsyncJs(String js, [arg]) : super(js, arg);

  /**
   * If [context] is a [WebElement] it will be passed as the second to last
   * argument to the script (the callback to signal completion is always the
   * last argument).
   */
  @override
  ScriptExecutor executor(SearchContext context) => context.driver.executeAsync;
}
