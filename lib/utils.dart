import 'dart:io';

import 'package:browser_data/browsers.dart';
import 'package:logger/logger.dart';
import 'package:win32_registry/win32_registry.dart';

import 'generic.dart';

String _defaultBrowserWin() {
  final key = Registry.openPath(
    RegistryHive.currentUser,
    path:
        r'Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice',
  );
  var progId = key.getValueAsString('ProgId');
  if (progId == null) {
    throw Exception('Could not determine default browser');
  }

  return progId.toLowerCase();
}

Browser? defaultBrowser({String? sqlite3Path}) {
  var logger = Logger();

  String? browser;
  if (Platform.isWindows) {
    browser = _defaultBrowserWin();
  } else {
    logger.w('Default browser feature not supported on this OS');
    return null;
  }

  browser = browser.toLowerCase();

  var browsers = [
    Chromium(sqlite3Path: sqlite3Path),
    Chrome(sqlite3Path: sqlite3Path),
    Firefox(sqlite3Path: sqlite3Path),
    LibreWolf(sqlite3Path: sqlite3Path),
    Safari(sqlite3Path: sqlite3Path),
    Edge(sqlite3Path: sqlite3Path),
    Opera(sqlite3Path: sqlite3Path),
    OperaGX(sqlite3Path: sqlite3Path),
    Brave(sqlite3Path: sqlite3Path),
    Vivaldi(sqlite3Path: sqlite3Path),
  ];

  for (var b in browsers) {
    var aliases = b.aliases ?? [];

    if (b.name == browser || aliases.contains(browser)) {
      return b;
    }
  }
  logger.w('Current default browser is not supported');
  return null;
}

extension StringExtension on String {
  String sub(String input) {
    if (input.contains(':')) {
      if (RegExp(r':((-|)\d)').hasMatch(input)) {
        var r = RegExp(r':((-|)\d)').matchAsPrefix(input);
        var value = int.parse(r!.group(1)!);

        return substring(0, value.isNegative ? length + value : value);
      } else {
        var r = RegExp(r'((-|)\d):').matchAsPrefix(input);
        var value = int.parse(r!.group(1)!);
        return substring(length + value);
      }
    } else {
      var r = RegExp(r'((-|)\d)').matchAsPrefix(input);
      var value = int.parse(r!.group(1)!);
      var p = length + value;
      return substring(p, p + 1);
    }
  }
}
