import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

void getBrowsers() {}

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

String? defaultBrowser() {
  if (Platform.isWindows) {
    return _defaultBrowserWin();
  }
  return null;
}
