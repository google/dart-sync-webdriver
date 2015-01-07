library pageloader_test;

import 'package:unittest/compact_vm_config.dart';
import 'package:unittest/unittest.dart';
import 'package:sync_webdriver/sync_pageloader.dart';
import 'package:sync_webdriver/sync_webdriver.dart';
import 'test_util.dart';

/**
 * These tests are not expected to be run as part of normal automated testing,
 * as they are slow and they have external dependencies.
 */
void main() {
  useCompactVMConfiguration();

  WebDriver driver;
  PageLoader loader;

  setUp(() {
    driver = freshDriver;
    driver.url = testPagePath;
    loader = new PageLoader(driver);
  });

  verifyRows(List<Row> rows) {
    expect(rows, hasLength(2));
    expect(rows[0].cells, hasLength(2));
    expect(rows[1].cells, hasLength(2));
    expect(rows[0].cells[0].text, 'r1c1');
    expect(rows[0].cells[1].text, 'r1c2');
    expect(rows[1].cells[0].text, 'r2c1');
    expect(rows[1].cells[1].text, 'r2c2');
  }

  verifyTable(Table table) {
    verifyRows(table.rows);
  }

  test('simple', () {
    PageForSimpleTest page = loader.getInstance(PageForSimpleTest);
    expect(page.table.root.name, 'table');
    verifyTable(page.table);
    expect(page.driver, driver);
    expect(page.loader, loader);
  });

  test('class annotations', () {
    Table table = loader.getInstance(Table);
    expect(table.root.name, 'table');
    verifyTable(table);
  });

  test('class annotation on nested field', () {
    PageForClassAnnotationTest page =
        loader.getInstance(PageForClassAnnotationTest);
    expect(page.table.root.name, 'table');
    verifyTable(page.table);
  });

  test('sub-class', () {
    SubclassPage page = loader.getInstance(SubclassPage);
    verifyTable(page.table);
    expect(page.driver, driver);
    expect(page.loader, loader);
  });

  test('displayed filtering', () {
    PageForDisplayedFilteringTest page =
        loader.getInstance(PageForDisplayedFilteringTest);
    expect(page.shouldHaveOneElement, hasLength(1));
    expect(page.shouldBeEmpty, isEmpty);
    expect(page.shouldAlsoBeEmpty, isEmpty);
  });

  test('setters', () {
    PageForSettersTest page = loader.getInstance(PageForSettersTest);
    expect(page._shouldHaveOneElement, hasLength(1));
  });

  test('skip finals', () {
    PageForSkipFinalTest page = loader.getInstance(PageForSkipFinalTest);
    expect(page.shouldHaveOneElement, hasLength(1));
    expect(page.shouldBeNull, isNull);
  });

  test('skip fields without finders', () {
    PageForSkipFieldsWithoutFinderTest page =
        loader.getInstance(PageForSkipFieldsWithoutFinderTest);
    expect(page.shouldHaveOneElement, hasLength(1));
    expect(page.shouldBeNull, isNull);
  });

  test('no matching element', () {
    expect(() => loader.getInstance(PageForNoMatchingElementTest), throws);
  });

  test('no matching class element', () {
    expect(() => loader.getInstance(PageForNoMatchingClassElementTest), throws);
  });

  test('no matching but nullable element', () {
    PageForNullableElementTest page =
        loader.getInstance(PageForNullableElementTest);
    expect(page.doesntExist, isNull);
  });

  test('multiple matching element', () {
    expect(
        () => loader.getInstance(PageForMultipleMatchingElementTest), throws);
  });

  test('multiple matching element', () {
    expect(() => loader.getInstance(PageForMultipleMatchingClassElementTest),
        throws);
  });

  test('multiple finders', () {
    expect(() => loader.getInstance(PageForMultipleFinderTest), throws);
  });

  test('multiple class finders', () {
    expect(() => loader.getInstance(PageForMultipleClassFinderTest), throws);
  });

  test('invalid constructor', () {
    expect(() => loader.getInstance(PageForInvalidConstructorTest), throws);
  });

  test('ByJs', () {
    PageForByJsTest page = loader.getInstance(PageForByJsTest);
    verifyTable(page.table);
  });

  test('WithAttribute', () {
    PageForWithAttributeTest page =
        loader.getInstance(PageForWithAttributeTest);
    expect(page.element.attributes['type'], 'checkbox');
  });

  test('ambiguous element test', () {
    expect(() => loader.getInstance(PageForAmbiguousTest), throws);
  });

  test('mixin', () {
    PageForMixinTest page = loader.getInstance(PageForMixinTest);
    verifyTable(page.table);
    expect(page.driver, driver);
    expect(page.loader, loader);
    expect(page.shouldHaveOneElement, hasLength(1));
    expect(page.shouldBeEmpty, isEmpty);
    expect(page.shouldAlsoBeEmpty, isEmpty);
  });

  test('private constructor', () {
    PageForPrivateConstructorTest page =
        loader.getInstance(PageForPrivateConstructorTest);

    expect(page.table.rows, hasLength(2));
    expect(page.table.rows[0].cells, hasLength(2));
    expect(page.table.rows[1].cells, hasLength(2));
    expect(page.table.rows[0].cells[0].text, 'r1c1');
    expect(page.table.rows[0].cells[1].text, 'r1c2');
    expect(page.table.rows[1].cells[0].text, 'r2c1');
    expect(page.table.rows[1].cells[1].text, 'r2c2');
    expect(page.driver, driver);
    expect(page.loader, loader);
  });

  test('private fields', () {
    PageForPrivateFieldsTest page =
        loader.getInstance(PageForPrivateFieldsTest);
    verifyTable(page.table);
    expect(page.driver, driver);
    expect(page.loader, loader);
  });

  // TODO(DrMarcII) Change if private setters get fixed.
  test('private setters', () {
    PageForPrivateSettersTest page =
        loader.getInstance(PageForPrivateSettersTest);
    expect(page.table, isNull);
    expect(page.driver, isNull);
    expect(page.loader, isNull);
//    expect(page.table.rows, hasLength(2));
//    expect(page.table.rows[0].cells, hasLength(2));
//    expect(page.table.rows[1].cells, hasLength(2));
//    expect(page.table.rows[0].cells[0].text, 'r1c1');
//    expect(page.table.rows[0].cells[1].text, 'r1c2');
//    expect(page.table.rows[1].cells[0].text, 'r2c1');
//    expect(page.table.rows[1].cells[1].text, 'r2c2');
//    expect(page.driver, driver);
//    expect(page.loader, loader);
  });

  test('static field', () {
    PageForStaticFieldsTest page = loader.getInstance(PageForStaticFieldsTest);
    verifyTable(page.table);
    expect(page.driver, driver);
    expect(page.loader, loader);
    expect(PageForStaticFieldsTest.dontSet, isNull);
  });

  test('static setter', () {
    PageForStaticSettersTest page =
        loader.getInstance(PageForStaticSettersTest);
    verifyTable(page.table);
    expect(page.driver, driver);
    expect(page.loader, loader);
    expect(PageForStaticFieldsTest.dontSet, isNull);
  });

  test('function field', () {
    PageForFunctionTest page = loader.getInstance(PageForFunctionTest);
    // Functions
    expect(page.noReturnsFn().text, 'r1c1 r1c2\nr2c1 r2c2');
    expect(page.noTypeFn().text, 'r1c1 r1c2\nr2c1 r2c2');
    expect(page.webElementFn().text, 'r1c1 r1c2\nr2c1 r2c2');
    verifyTable(page.tableFn());
    // Functions + Lists
    expect(page.noTypesFn(), hasLength(2));
    expect(page.returnsGenericListFn(), hasLength(2));
    expect(page.webElementsFn(), hasLength(2));
    verifyRows(page.rowsFn());
    // TypeDefs
    expect(page.noTypeDef().text, 'r1c1 r1c2\nr2c1 r2c2');
    expect(page.webElementTypeDef().text, 'r1c1 r1c2\nr2c1 r2c2');
    verifyTable(page.tableTypeDef());
    // TypeDefs + Lists
    expect(page.noListTypeDef(), hasLength(2));
    expect(page.webElementsTypeDef(), hasLength(2));
    verifyRows(page.rowsTypeDef());
  });

  // This test needs to be last to properly close the browser.
  test('one-time teardown', () {
    closeDriver();
  });
}

class PageForSimpleTest {
  WebDriver driver;

  PageLoader loader;

  @By.tagName('table')
  Table table;
}

class SubclassPage extends PageForSimpleTest {}

@By.tagName('table')
@Optional
class Table {
  @Root
  WebElement root;

  @By.tagName('tr')
  List<Row> rows;
}

class Row {
  @By.tagName('td')
  List<WebElement> cells;
}

class PageForClassAnnotationTest {
  @Root
  Table table;
}

class PageForDisplayedFilteringTest {
  @By.id('div')
  @WithState.present()
  List<WebElement> shouldHaveOneElement;

  @By.id('div')
  List<WebElement> shouldBeEmpty;

  @By.id('div')
  @WithState.visible()
  List shouldAlsoBeEmpty;
}

class PageForSettersTest {
  List<WebElement> _shouldHaveOneElement;

  @By.id('div')
  @WithState.present()
  set shouldHaveOneElement(List<WebElement> elements) {
    _shouldHaveOneElement = elements;
  }
}

class PageForSkipFinalTest {
  @By.id('div')
  @WithState.present()
  List<WebElement> shouldHaveOneElement;

  @By.id('div')
  @WithState.present()
  final List<WebElement> shouldBeNull = null;
}

class PageForSkipFieldsWithoutFinderTest {
  @By.id('div')
  @WithState.present()
  List<WebElement> shouldHaveOneElement;

  @WithState.present()
  List<WebElement> shouldBeNull;
}

class PageForNoMatchingElementTest {
  @By.id('non-existent id')
  WebElement doesntExist;
}

@By.id('non-existent id')
class PageForNoMatchingClassElementTest {
  @Root
  WebElement doesntExist;
}

class PageForNullableElementTest {
  @By.id('non-existent id')
  @Optional
  WebElement doesntExist;
}

class PageForMultipleMatchingElementTest {
  @By.tagName('td')
  WebElement doesntExist;
}

@By.tagName('td')
class PageForMultipleMatchingClassElementTest {
  @Root
  WebElement doesntExist;
}

class PageForMultipleFinderTest {
  @By.id('non-existent id')
  @By.name('a-name')
  WebElement multipleFinder;
}

@By.id('non-existent id')
@By.name('a-name')
class PageForMultipleClassFinderTest {
  @Root
  WebElement multipleFinder;
}

class PageForInvalidConstructorTest {
  PageForInvalidConstructorTest(String someArg);

  @By.id('div')
  @WithState.present()
  List<WebElement> shouldHaveOneElement;
}

class PageForByJsTest {
  @ByJs('return document.getElementById(arguments[0]);', 'table1')
  Table table;
}

class PageForWithAttributeTest {
  @By.tagName('input')
  @WithAttribute('type', 'checkbox')
  WebElement element;
}

class PageForAmbiguousTest {
  @By.tagName('input')
  WebElement element;
}

class PageForMixinTest extends PageForSimpleTest
    with PageForDisplayedFilteringTest {}

class PageForPrivateConstructorTest extends PageForSimpleTest {
  PageForPrivateConstructorTest._();
}

class PageForPrivateFieldsTest {
  @By.tagName('table')
  Table _table;

  WebDriver _driver;

  PageLoader _loader;

  WebDriver get driver => _driver;
  PageLoader get loader => _loader;
  Table get table => _table;
}

class PageForPrivateSettersTest {
  Table table;

  dynamic driver;

  dynamic loader;

  set _driver(WebDriver d) => driver = d;
  set _loader(PageLoader l) => loader = l;
  @By.tagName('table')
  set _table(Table t) => table = t;
}

class PageForStaticFieldsTest extends PageForSimpleTest {
  @By.tagName("table")
  static WebElement dontSet;
}

class PageForStaticSettersTest extends PageForSimpleTest {
  static var _dontSet;

  @By.tagName("table")
  static set dontSet(WebElement el) {
    _dontSet = el;
  }

  static get dontSet => _dontSet;
}

typedef NoTypeFn();

typedef WebElement WebElementFn();

typedef Table TableFn();

typedef List NoListTypeFn();

typedef List<WebElement> WebElementsFn();

typedef List<Row> RowsFn();

class PageForFunctionTest {

  // Functions

  @By.tagName('table')
  Function noReturnsFn;

  @By.tagName('table')
  @Returns(WebElement)
  var noTypeFn;

  @By.tagName('table')
  @Returns(WebElement)
  Function webElementFn;

  @By.tagName('table')
  @Returns(Table)
  Function tableFn;

  // Functions + Lists

  @By.cssSelector('table tr')
  @Returns(List)
  var noTypesFn;

  @By.cssSelector('table tr')
  @Returns(List)
  Function returnsGenericListFn;

  @By.cssSelector('table tr')
  @ReturnsList(WebElement)
  Function webElementsFn;

  @By.cssSelector('table tr')
  @ReturnsList(Row)
  Function rowsFn;

  // TypeDefs

  @By.tagName('table')
  NoTypeFn noTypeDef;

  @By.tagName('table')
  WebElementFn webElementTypeDef;

  @By.tagName('table')
  TableFn tableTypeDef;

  // TypeDefs + Lists

  @By.cssSelector('table tr')
  NoListTypeFn noListTypeDef;

  @By.cssSelector('table tr')
  WebElementsFn webElementsTypeDef;

  @By.cssSelector('table tr')
  RowsFn rowsTypeDef;
}
