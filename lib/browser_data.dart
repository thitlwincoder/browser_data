import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

import 'browsers.dart';
import 'model.dart';

class BrowserData {
  BrowserData() {
    open.overrideForAll(() {
      return DynamicLibrary.open('../sqlite3.dll');
    });
  }

  Future<List<History>> getHistory() {
    var browser = Chrome();
    return browser.fetchHistory();
  }

  Future<Bookmark?> getBookmark() {
    var browser = Chrome();
    return browser.fetchBookmarks();
  }
}
