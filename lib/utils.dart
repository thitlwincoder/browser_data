import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

void getBrowsers() {}

String _defaultBrowserWin() {
  if (!Platform.isWindows) {}

  final key = Registry.openPath(
    RegistryHive.currentUser,
    path:
        r'Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice',
  );
  var progId = key.getValueAsString('ProgId');
  if (progId == null) {
    throw Exception('Could not determine default browser');
  }

  return progId[0].toLowerCase();
}

void defaultBrowser() {
  if (Platform.isWindows) {
    _defaultBrowserWin();
  }
}
