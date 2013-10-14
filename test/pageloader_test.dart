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

  test('multiple matching element', () {
    expect(() => loader.getInstance(PageForMultipleMatchingElementTest),
        throws);
  });

  test('multiple finders', () {
    expect(() => loader.getInstance(PageForMultipleFinderTest), throws);
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

class Table {
  @By.tagName('tr')
  @ListOf(Row)
  List<Row> rows;
}

class Row {
  @By.tagName('td')
  List<WebElement> cells;
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

class PageForMultipleMatchingElementTest {
  @By.tagName('td')
  WebElement doesntExist;
}

class PageForMultipleFinderTest {
  @By.id('non-existent id') @By.name('a-name')
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
