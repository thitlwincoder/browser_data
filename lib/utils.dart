import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:browser_data/browsers.dart';
import 'package:ffi/ffi.dart';
import 'package:logger/logger.dart';
import 'package:win32/win32.dart';
import 'package:win32_registry/win32_registry.dart';

import 'generic.dart';

String? _defaultBrowserLinux() {
  try {
    var rawResult = Process.runSync(
      'xdg-settings',
      ['get', 'default-web-browser'],
    );

    return rawResult.stdout
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('.desktop', '');
  } catch (e) {
    Logger().d('Could not determine default browser');
    return null;
  }
}

String _defaultBrowserWin() {
  final key = Registry.openPath(
    RegistryHive.currentUser,
    path:
        r'Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice',
  );
  var progId = key.getStringValue('ProgId');
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
  } else if (Platform.isLinux) {
    browser = _defaultBrowserLinux();
  } else {
    logger.w('Default browser feature not supported on this OS');
    return null;
  }

  if (browser == null) {
    logger.w('No default browser found');
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

    if (b.name.toLowerCase() == browser || aliases.contains(browser)) {
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

DateTime dateParse(String date) {
  return DateTime.fromMicrosecondsSinceEpoch(int.parse(date));
}

Future<Uint8List?> cryptUnprotectData(Uint8List encryptedData) async {
  final encryptedBlob = calloc<CRYPT_INTEGER_BLOB>();
  final decryptedBlob = calloc<CRYPT_INTEGER_BLOB>();

  try {
    // Allocate and set the input DATA_BLOB
    encryptedBlob.ref.pbData = calloc<Uint8>(encryptedData.length);
    encryptedBlob.ref.cbData = encryptedData.length;
    encryptedBlob.ref.pbData
        .asTypedList(encryptedData.length)
        .setAll(0, encryptedData);

    // Call CryptUnprotectData
    final result = CryptUnprotectData(
      encryptedBlob,
      nullptr,
      nullptr,
      nullptr,
      nullptr,
      0,
      decryptedBlob,
    );

    if (result == 0) {
      // Decryption failed
      final error = GetLastError();
      print('CryptUnprotectData failed with error: $error');
      return null;
    } else {
      // Decryption succeeded, copy the output data
      final decryptedData =
          decryptedBlob.ref.pbData.asTypedList(decryptedBlob.ref.cbData);
      return Uint8List.fromList(decryptedData);
    }
  } finally {
    // Free allocated memory
    if (encryptedBlob.ref.pbData != nullptr) {
      calloc.free(encryptedBlob.ref.pbData);
    }
    if (decryptedBlob.ref.pbData != nullptr) {
      LocalFree(decryptedBlob.ref.pbData);
    }
    calloc.free(encryptedBlob);
    calloc.free(decryptedBlob);
  }
}

Future<void> copyFile(File file, String path) async {
  final newPath = file.absolute.path.replaceFirst(file.path, path);

  final newFile = File.fromUri(Uri.file(newPath));

  if (!await newFile.exists()) {
    await newFile.create(recursive: true);
  }

  final stream = file.openRead();

  final sink = newFile.openWrite();

  await for (final bytes in stream) {
    sink.add(bytes);

    await sink.flush();
  }

  await sink.close();
}
