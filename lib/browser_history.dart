import 'dart:ffi';

import 'package:browser_history/browsers.dart';
import 'package:browser_history/model.dart';
import 'package:sqlite3/open.dart';

class BrowserHistory {
  BrowserHistory() {
    open.overrideForAll(() => DynamicLibrary.open('../sqlite3.dll'));
  }

  Future<List<History>> getHistory() {
    var browser = Chrome();
    return browser.fetchHistory();
  }
}

const sqlite3WindowsLibraryPath =
    '\\data\\flutter_assets\\packages\\browser_history\\sqlite3.dll';
