import 'dart:convert';

import 'package:browser_data/browser_data.dart';

Future<void> main(List<String> args) async {
  // get default browser from device
  var browser = defaultBrowser(sqlite3Path: './sqlite3.dll');

  // get specific browser
  browser = Chromium(sqlite3Path: './sqlite3.dll');

  // get history from this browser
  var histories = await browser.fetchHistory(limit: 2);

  // get bookmarks from this browser
  var bookmarks = await browser.fetchBookmarks();
}

void formatPrint(Map<String, dynamic> map) {
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(map);
  return print(prettyprint);
}
