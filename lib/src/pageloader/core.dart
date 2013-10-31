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
 * Mechanism for specifying hierarchical page objects using annotations on
 * fields in simple Dart objects.
 */
class PageLoader {
  final WebDriver _driver;

  PageLoader(this._driver);

  /**
   * Creates a new instance of [type] and binds annotated fields to
   * corresponding [WebElement]s.
   */
  getInstance(Type type, [SearchContext context]) {
    if (context == null) {
      context = _driver;
    }
    return _getInstance(reflectClass(type), context);
  }

  _getInstance(ClassMirror type, SearchContext context) {
    var fieldInfos = _fieldInfos(type);
    var instance = _reflectedInstance(type);

    for (var fieldInfo in fieldInfos) {
      fieldInfo.setField(instance, context, this);
    }

    return instance.reflectee;
  }

  InstanceMirror _reflectedInstance(ClassMirror aClass) {
    InstanceMirror page;

    for (MethodMirror constructor in aClass.constructors.values) {
      if (constructor.parameters.isEmpty && !constructor.isPrivate) {
        page = aClass.newInstance(constructor.constructorName, []);
        break;
      }
    }

    if (page == null) {
      throw new StateError('$aClass has no acceptable constructors');
    }
    return page;
  }

  Iterable<_FieldInfo> _fieldInfos(ClassMirror type) {
    var infos = <_FieldInfo>[];

    for (var current in _allTypes(type)) {
      for (DeclarationMirror decl in current.declarations.values) {
        _FieldInfo info = new _FieldInfo(decl);
        if (info != null) {
          infos.add(info);
        }
      }
    }

    return infos;
  }

  Iterable<ClassMirror> _allTypes(ClassMirror type) {
    var typesToProcess = [ type ];
    var allTypes = new Set();

    while (typesToProcess.isNotEmpty) {
      var current = typesToProcess.removeLast();
      if (!allTypes.contains(current)) {
        allTypes.add(current);
        if (current.superclass != null) {
          typesToProcess.add(current.superclass);
        }
        if (current.mixin != null) {
          typesToProcess.add(current.mixin);
        }
      }
    }

    return allTypes;
  }
}

abstract class _FieldInfo {

  factory _FieldInfo(DeclarationMirror field) {
    var finder;
    var filters = new List<Filter>();
    var type;
    var name;

    if (field is VariableMirror && !field.isFinal &&
        !field.isStatic) { // TODO(DrMarcII) && !field.isConst
      type = field.type;
      name = field.simpleName;
    } else if (field is MethodMirror && field.isSetter &&
        !field.isStatic && !field.isPrivate) {
      type = field.parameters.first.type;
      // HACK to get correct symbol name for operating with setField.
      name = field.simpleName.toString();
      name = new Symbol(name.substring(8, name.length - 3));
    } else {
      return null;
    }

    var isList = false;
    if (type.simpleName == const Symbol('List')) {
      isList = true;
      type = null;
    }

    var isOptional = false;

    var implicitDisplayFiltering = true;

    for (InstanceMirror metadatum in field.metadata) {
      if (!metadatum.hasReflectee) {
        continue;
      }
      var datum = metadatum.reflectee;

      if (datum is Finder) {
        if (finder != null) {
          throw new StateError('Cannot have multiple finders on field');
        }
        finder = datum;
      } else if (datum is Filter) {
        filters.add(datum);
      } else if (datum is ListOf) {
        if (type != null && type.simpleName != const Symbol('dynamic')) {
          throw new StateError('Field type is not compatible with ListOf');
        }
        isList = true;
        type = reflectClass(datum.type);
      } else if (datum is _Optional) {
        isOptional = true;
      }

      if (datum is HasFilterFinderOptions &&
          datum.options.contains(
              FilterFinderOption.DISABLE_IMPLICIT_DISPLAY_FILTERING)) {
        implicitDisplayFiltering = false;
      }
    }

    if (type == null || type.simpleName == const Symbol('dynamic')) {
      type = reflectClass(WebElement);
    }

    if (implicitDisplayFiltering) {
      filters.insert(0, const WithState.visible());
    }

    if (finder != null) {
      return new _FinderFieldInfo(name, finder, filters, type, isList, isOptional);
    } else if (type.simpleName == const Symbol('PageLoader')) {
      return new _InjectedPageLoaderInfo(name);
    } else if (type.simpleName == const Symbol('WebDriver')) {
      return new _InjectedWebDriverInfo(name);
    } else {
      return null;
    }
  }

  void setField(
      InstanceMirror instance,
      SearchContext context,
      PageLoader loader);
}

class _InjectedPageLoaderInfo implements _FieldInfo {
  final Symbol _fieldName;

  _InjectedPageLoaderInfo(this._fieldName);

  @override
  void setField(InstanceMirror instance, _, PageLoader loader) {
    instance.setField(_fieldName, loader);
  }
}

class _InjectedWebDriverInfo implements _FieldInfo {
  final Symbol _fieldName;

  _InjectedWebDriverInfo(this._fieldName);

  @override
  void setField(InstanceMirror instance, _, PageLoader loader) {
    instance.setField(_fieldName, loader._driver);
  }
}

class _FinderFieldInfo implements _FieldInfo {
  final Symbol _fieldName;
  final Finder _finder;
  final List<Filter> _filters;
  final ClassMirror _instanceType;
  final bool _isList;
  final bool _isOptional;

  _FinderFieldInfo(
      this._fieldName,
      this._finder,
      this._filters,
      this._instanceType,
      this._isList,
      this._isOptional);

  @override
  void setField(
      InstanceMirror instance,
      SearchContext context,
      PageLoader loader) {
    List elements = _getElements(context);

    if (!_isList) {
      if (elements.isEmpty && !_isOptional) {
        throw new StateError('Unable to find element for non-nullable, non-list'
            ' field $_fieldName');
      }

      if (elements.length > 1) {
        throw new StateError(
            'Found ${elements.length} elements for non-list field $_fieldName');
      }
    }

    if (_instanceType.simpleName != const Symbol('WebElement')) {
      elements = elements.map((element) =>
          loader._getInstance(_instanceType, element)).toList();
    }

    if (_isList) {
      instance.setField(_fieldName, new UnmodifiableListView(elements));
    } else {
      instance.setField(_fieldName, elements.isEmpty ? null : elements[0]);
    }
  }

  List<WebElement> _getElements(SearchContext context) {
    List<WebElement> elements = _finder.findElements(context);
    for (var filter in _filters) {
      elements = filter.filter(elements);
    }
    return elements;
  }
}

/**
 * Enum of options for that can be returned by
 *  [HasFilterFinderOptions.options].
 */
class FilterFinderOption {
  final String option;

  const FilterFinderOption._(this.option);

  /// Disable the default implicit display filtering for a field.
  static const FilterFinderOption DISABLE_IMPLICIT_DISPLAY_FILTERING =
      const FilterFinderOption._('DISABLE_IMPLICIT_DISPLAY_FILTERING');
}

abstract class HasFilterFinderOptions {
  const HasFilterFinderOptions();

  List<FilterFinderOption> get options;
}

abstract class Filter {
  const Filter();

  List<WebElement> filter(List<WebElement> elements);
}

abstract class ElementFilter implements Filter {
  const ElementFilter();

  List<WebElement> filter(List<WebElement> elements) =>
      new UnmodifiableListView<WebElement>(elements.where(keep));

  bool keep(WebElement element);
}


class ListOf {
  final Type type;

  const ListOf([this.type = WebElement]);
}

class WithState extends ElementFilter implements HasFilterFinderOptions {

  final bool _displayed;

  const WithState._(this._displayed);

  const WithState.present() : this._(null);

  const WithState.visible() : this._(true);

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
