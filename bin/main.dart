import 'dart:convert';

import 'package:browser_data/browsers.dart';

Future<void> main(List<String> args) async {
  var chrome = Chrome(sqlite3Path: './sqlite3.dll');
  var history = await chrome.fetchHistory();

  for (var e in history) {
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(e.toJson());
    print(prettyprint);
  }
}
