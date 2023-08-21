import 'dart:convert';

import 'package:browser_data/browsers.dart';

Future<void> main(List<String> args) async {
  var chrome = Chrome(sqlite3Path: './sqlite3.dll');
  var history = await chrome.fetchHistory();

  for (var e in history) {
    formatPrint(e.toJson());
  }
}

void formatPrint(Map<String, dynamic> map) {
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(map);
  return print(prettyprint);
}
