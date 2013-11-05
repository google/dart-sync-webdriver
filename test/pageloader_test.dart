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

  test('simple', () {
    PageForSimpleTest page = loader.getInstance(PageForSimpleTest);
    expect(page.table.root.name, 'table');
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

  test('class annotations', () {
    Table page = loader.getInstance(Table);
    expect(page.root.name, 'table');
    expect(page.rows, hasLength(2));
    expect(page.rows[0].cells, hasLength(2));
    expect(page.rows[1].cells, hasLength(2));
    expect(page.rows[0].cells[0].text, 'r1c1');
    expect(page.rows[0].cells[1].text, 'r1c2');
    expect(page.rows[1].cells[0].text, 'r2c1');
    expect(page.rows[1].cells[1].text, 'r2c2');
  });

  test('class annotation on nested field', () {
    PageForClassAnnotationTest page = loader.getInstance(PageForClassAnnotationTest);
    expect(page.table.root.name, 'table');
    expect(page.table.rows, hasLength(2));
    expect(page.table.rows[0].cells, hasLength(2));
    expect(page.table.rows[1].cells, hasLength(2));
    expect(page.table.rows[0].cells[0].text, 'r1c1');
    expect(page.table.rows[0].cells[1].text, 'r1c2');
    expect(page.table.rows[1].cells[0].text, 'r2c1');
    expect(page.table.rows[1].cells[1].text, 'r2c2');
  });

  test('sub-class', () {
    SubclassPage page = loader.getInstance(SubclassPage);
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
    PageForNullableElementTest page = loader.getInstance(PageForNullableElementTest);
    expect(page.doesntExist, isNull);
  });

  test('multiple matching element', () {
    expect(() => loader.getInstance(PageForMultipleMatchingElementTest),
        throws);
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
    expect(page.table.rows, hasLength(2));
    expect(page.table.rows[0].cells, hasLength(2));
    expect(page.table.rows[1].cells, hasLength(2));
    expect(page.table.rows[0].cells[0].text, 'r1c1');
    expect(page.table.rows[0].cells[1].text, 'r1c2');
    expect(page.table.rows[1].cells[0].text, 'r2c1');
    expect(page.table.rows[1].cells[1].text, 'r2c2');
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
    expect(page.table.rows, hasLength(2));
    expect(page.table.rows[0].cells, hasLength(2));
    expect(page.table.rows[1].cells, hasLength(2));
    expect(page.table.rows[0].cells[0].text, 'r1c1');
    expect(page.table.rows[0].cells[1].text, 'r1c2');
    expect(page.table.rows[1].cells[0].text, 'r2c1');
    expect(page.table.rows[1].cells[1].text, 'r2c2');
    expect(page.driver, driver);
    expect(page.loader, loader);
    expect(page.shouldHaveOneElement, hasLength(1));
    expect(page.shouldBeEmpty, isEmpty);
    expect(page.shouldAlsoBeEmpty, isEmpty);
  });

  // TODO(DrMarcII) Change if private constructors get fixed.
  test('private constructor', () {
    expect(() => loader.getInstance(PageForPrivateConstructorTest), throws);
//    PageForPrivateConstructorTest page =
//        loader.getInstance(PageForPrivateConstructorTest);
//
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

  test('private fields', () {
    PageForPrivateFieldsTest page =
        loader.getInstance(PageForPrivateFieldsTest);
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
    expect(page.table.rows, hasLength(2));
    expect(page.table.rows[0].cells, hasLength(2));
    expect(page.table.rows[1].cells, hasLength(2));
    expect(page.table.rows[0].cells[0].text, 'r1c1');
    expect(page.table.rows[0].cells[1].text, 'r1c2');
    expect(page.table.rows[1].cells[0].text, 'r2c1');
    expect(page.table.rows[1].cells[1].text, 'r2c2');
    expect(page.driver, driver);
    expect(page.loader, loader);
    expect(PageForStaticFieldsTest.dontSet, isNull);
  });

  test('static setter', () {
    PageForStaticSettersTest page = loader.getInstance(PageForStaticSettersTest);
    expect(page.table.rows, hasLength(2));
    expect(page.table.rows[0].cells, hasLength(2));
    expect(page.table.rows[1].cells, hasLength(2));
    expect(page.table.rows[0].cells[0].text, 'r1c1');
    expect(page.table.rows[0].cells[1].text, 'r1c2');
    expect(page.table.rows[1].cells[0].text, 'r2c1');
    expect(page.table.rows[1].cells[1].text, 'r2c2');
    expect(page.driver, driver);
    expect(page.loader, loader);
    expect(PageForStaticFieldsTest.dontSet, isNull);
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

@By.tagName('table') @Optional
class Table {
  @Root
  WebElement root;

  @By.tagName('tr')
  @ListOf(Row)
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
  @By.id('div') @WithState.present()
  List<WebElement> shouldHaveOneElement;

  @By.id('div')
  List<WebElement> shouldBeEmpty;

  @By.id('div') @WithState.visible()
  @ListOf()
  dynamic shouldAlsoBeEmpty;
}

class PageForSettersTest {
  List<WebElement> _shouldHaveOneElement;

  @By.id('div') @WithState.present()
  set shouldHaveOneElement(List<WebElement> elements) {
    _shouldHaveOneElement = elements;
  }
}

class PageForSkipFinalTest {
  @By.id('div') @WithState.present()
  List<WebElement> shouldHaveOneElement;

  @By.id('div') @WithState.present()
  final List<WebElement> shouldBeNull = null;
}

class PageForSkipFieldsWithoutFinderTest {
  @By.id('div') @WithState.present()
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
  @By.id('non-existent id') @By.name('a-name')
  WebElement multipleFinder;
}

@By.id('non-existent id') @By.name('a-name')
class PageForMultipleClassFinderTest {
  @Root
  WebElement multipleFinder;
}

class PageForInvalidConstructorTest {
  PageForInvalidConstructorTest(String someArg);

  @By.id('div') @WithState.present()
  List<WebElement> shouldHaveOneElement;
}

class PageForByJsTest {
  @ByJs('return document.getElementById(arguments[0]);', 'table1')
  Table table;
}

class PageForWithAttributeTest {
  @By.tagName('input') @WithAttribute('type', 'checkbox')
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

class PageForStaticSettersTest extends PageForSimpleTest{
  static var _dontSet;

  @By.tagName("table")
  static set dontSet(WebElement el) { _dontSet = el; }

  static get dontSet => _dontSet;
}