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

/**
 * Matches the root [WebElement] being used for constructing the current page
 * object.
 */
class Root implements Finder, HasFilterFinderOptions {
  const Root();

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
      throw new NoSuchElementError(-1,
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

class ByJs extends _ByScript {

  const ByJs(String js, [arg]) : super(js, arg);

  @override
  ScriptExecutor executor(SearchContext context) => context.driver.execute;
}

class ByAsyncJs extends _ByScript {

  const ByAsyncJs(String js, [arg]) : super(js, arg);

  @override
  ScriptExecutor executor(SearchContext context) => context.driver.executeAsync;
}
