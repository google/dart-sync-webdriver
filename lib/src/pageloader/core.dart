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

  _getInstance(ClassMirror type, SearchContext context) =>
      new _ClassInfo(type).getInstance(context, this);
}

class _ClassInfo {
  static final Map<ClassMirror, _ClassInfo> _classInfoCache =
      <ClassMirror, _ClassInfo>{};

  final ClassMirror _class;
  final List<_FieldInfo> _fields;
  final Finder _finder;
  final List<Filter> _filters;
  final bool _finderIsOptional;

  factory _ClassInfo(ClassMirror type) => _classInfoCache.putIfAbsent(type, () {
    Finder finder = null;
    List<Filter> filters = <Filter>[];
    bool finderIsOptional = false;
    for (InstanceMirror metadatum in type.metadata) {
      if (!metadatum.hasReflectee) {
        continue;
      }
      var datum = metadatum.reflectee;
      if (datum is Finder) {
        if (finder != null) {
          throw new PageLoaderException('Multiple finders found on $type');
        }
        finder = datum;
      } else if (datum is Filter) {
        filters.add(datum);
      } else if (datum is _Optional) {
        finderIsOptional = true;
      }
    }

    return new _ClassInfo._(
        type, _fieldInfos(type), finder, filters, finderIsOptional);
  });

  _ClassInfo._(this._class, this._fields, this._finder, this._filters,
      this._finderIsOptional);

  static Iterable<_FieldInfo> _fieldInfos(ClassMirror type) {
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

  static Iterable<ClassMirror> _allTypes(ClassMirror type) {
    var typesToProcess = new ListQueue<ClassMirror>()..addLast(type);
    var allTypes = new Set<ClassMirror>();

    while (typesToProcess.isNotEmpty) {
      var current = typesToProcess.removeFirst();
      if (!allTypes.contains(current)) {
        allTypes.add(current);
        if (current.superclass != null) {
          typesToProcess.addLast(current.superclass);
        }
        if (current.mixin != null) {
          typesToProcess.addLast(current.mixin);
        }
      }
    }

    return allTypes;
  }

  dynamic getInstance(SearchContext context, PageLoader loader) {
    try {
      if (_finder != null) {
        SearchContext ctx =
            _getElement(context, _finder, _filters, _finderIsOptional);
        if (ctx != null) {
          context = ctx;
        }
      }
      InstanceMirror page = _reflectedInstance();
      for (var fieldInfo in _fields) {
        fieldInfo.setField(page, context, loader);
      }

      return page.reflectee;
    } catch (e) {
      throw new PageLoaderException('Unable to create $_class caused by\n$e');
    }
  }

  InstanceMirror _reflectedInstance() {
    InstanceMirror page;

    for (DeclarationMirror constructor in _class.declarations.values) {
      if (constructor is MethodMirror &&
          constructor.isConstructor &&
          constructor.parameters.isEmpty) {
        page = _class.newInstance(constructor.constructorName, []);
        break;
      }
    }

    if (page == null) {
      throw new PageLoaderException('$_class has no acceptable constructors');
    }
    return page;
  }
}

abstract class _FieldInfo {
  factory _FieldInfo(DeclarationMirror field) {
    var finder;
    var filters = new List<Filter>();
    TypeMirror type;
    var name;

    if (field is VariableMirror &&
        !field.isFinal &&
        !field.isStatic &&
        !field.isConst) {
      type = field.type;
      name = field.simpleName;
      // TODO(DrMarcII): Support private setters when they work again
    } else if (field is MethodMirror &&
        field.isSetter &&
        !field.isStatic &&
        !field.isPrivate) {
      type = field.parameters.first.type;
      // HACK to get correct symbol name for operating with setField.
      name = field.simpleName.toString();
      name = name.substring(name.indexOf('"') + 1, name.indexOf('='));
      name = new Symbol(name);
    } else {
      return null;
    }

    var isFunction = false;
    if (type.simpleName == const Symbol('Function') || type is TypedefMirror) {
      isFunction = true;
      if (type is TypedefMirror) {
        type = (type as TypedefMirror).referent.returnType;
      } else {
        type = null;
      }
    }

    var isList = false;
    var isOptional = false;
    var implicitDisplayFiltering = true;

    for (InstanceMirror metadatum in field.metadata) {
      if (!metadatum.hasReflectee) {
        continue;
      }
      var datum = metadatum.reflectee;

      if (datum is Finder) {
        if (finder != null) {
          throw new PageLoaderException(
              'Cannot have multiple finders on field');
        }
        finder = datum;
      } else if (datum is Filter) {
        filters.add(datum);
      } else if (datum is Returns) {
        if (type != null && type.simpleName != const Symbol('dynamic')) {
          throw new PageLoaderException(
              'Field type is not compatible with Returns');
        }
        isFunction = true;
        if (datum is ReturnsList) {
          isList = true;
        }
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
    if (type != null && type.simpleName == const Symbol('List')) {
      isList = true;
      type = type.typeArguments.isNotEmpty ? type.typeArguments.single : null;
    }
    if (type == null || type.simpleName == const Symbol('dynamic')) {
      type = reflectClass(WebElement);
    }

    if (implicitDisplayFiltering) {
      filters.insert(0, const WithState.visible());
    }

    if (finder != null) {
      var fieldInfo = isList ?
          new _FinderListFieldInfo(name, finder, filters, type) :
          new _FinderSingleFieldInfo(name, finder, filters, type, isOptional);
      if (isFunction) {
        fieldInfo = new _FinderFunctionFieldInfo(fieldInfo);
      }
      return fieldInfo;
    } else if (type.simpleName == const Symbol('PageLoader')) {
      return new _InjectedPageLoaderInfo(name);
    } else if (type.simpleName == const Symbol('WebDriver')) {
      return new _InjectedWebDriverInfo(name);
    } else {
      return null;
    }
  }

  void setField(
      InstanceMirror instance, SearchContext context, PageLoader loader);
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

abstract class _FinderFieldInfo implements _FieldInfo {
  final Symbol _fieldName;

  _FinderFieldInfo(this._fieldName);

  calculateFieldValue(SearchContext context, PageLoader loader);

  @override
  void setField(
      InstanceMirror instance, SearchContext context, PageLoader loader) {
    try {
      instance.setField(_fieldName, calculateFieldValue(context, loader));
    } catch (e) {
      throw new PageLoaderException(
          'Unable to load field $_fieldName caused by\n$e');
    }
  }
}

class _FinderSingleFieldInfo extends _FinderFieldInfo {
  final Finder _finder;
  final List<Filter> _filters;
  final ClassMirror _instanceType;
  final bool _isOptional;

  _FinderSingleFieldInfo(Symbol fieldName, this._finder, this._filters,
      this._instanceType, this._isOptional) : super(fieldName);

  @override
  calculateFieldValue(SearchContext context, PageLoader loader) {
    var element = _getElement(context, _finder, _filters, _isOptional);
    if (_instanceType.simpleName != const Symbol('WebElement') &&
        element != null) {
      element = loader._getInstance(_instanceType, element);
    }
    return element;
  }
}

class _FinderListFieldInfo extends _FinderFieldInfo {
  final Finder _finder;
  final List<Filter> _filters;
  final ClassMirror _instanceType;

  _FinderListFieldInfo(
      Symbol fieldName, this._finder, this._filters, this._instanceType)
      : super(fieldName);

  @override
  calculateFieldValue(SearchContext context, PageLoader loader) {
    List elements = _getElements(context, _finder, _filters);
    if (_instanceType.simpleName != const Symbol('WebElement')) {
      elements = elements
          .map((element) => loader._getInstance(_instanceType, element))
          .toList();
    }
    return elements;
  }
}

class _FinderFunctionFieldInfo extends _FinderFieldInfo {
  _FinderFieldInfo _impl;

  _FinderFunctionFieldInfo(_FinderFieldInfo impl) : super(impl._fieldName) {
    this._impl = impl;
  }

  @override
  calculateFieldValue(SearchContext context, PageLoader loader) {
    return () => _impl.calculateFieldValue(context, loader);
  }
}

/// Enum of options that can be returned by [HasFilterFinderOptions.options].
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
      new UnmodifiableListView<WebElement>(
          elements.where(keep).toList(growable: false));

  bool keep(WebElement element);
}

class PageLoaderException {
  final String message;

  const PageLoaderException(this.message);

  String toString() => 'PageLoaderExeption: $message';
}

List<WebElement> _getElements(
    SearchContext context, Finder finder, List<Filter> filters) {
  List<WebElement> elements = finder.findElements(context);
  for (var filter in filters) {
    elements = filter.filter(elements);
  }
  return new UnmodifiableListView(elements);
}

WebElement _getElement(
    SearchContext context, Finder finder, List<Filter> filters, bool optional) {
  List<WebElement> elements = _getElements(context, finder, filters);
  if (elements.isEmpty) {
    if (!optional) {
      throw new PageLoaderException(
          'Unable to find element with finder: $finder and filters: $filters');
    }
    return null;
  }
  if (elements.length > 1) {
    throw new PageLoaderException(
        'Found ${elements.length} elements for finder: $finder and filters: $filters');
  }
  return elements[0];
}
