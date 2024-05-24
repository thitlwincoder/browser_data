import 'dart:convert';

import 'package:browser_data/browser_data.dart';

Future<void> main(List<String> args) async {
  // get default browser from device
  // var browser = defaultBrowser(sqlite3Path: './sqlite3.dll');

  // get specific browser
  var browser = Chrome(sqlite3Path: './sqlite3.dll');

  // get profiles
  var profiles = browser.fetchProfiles();
  print(profiles);

  // get history from browser
  var histories = await browser.fetchHistory(profiles: ['Profile 1']);
  print(histories);

  // get bookmarks from browser
  var bookmarks = await browser.fetchBookmarks(profiles: ['Default']);
  print(bookmarks);

  // get passwords from browser
  var passwords = await browser.fetchPasswords();
  print(passwords);
}

void formatPrint(Map<String, dynamic> map) {
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(map);
  return print(prettyprint);
}
