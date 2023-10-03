import 'dart:ffi';
import 'dart:typed_data';

// void getBrowsers() {}

// String _defaultBrowserWin() {
//   final key = Registry.openPath(
//     RegistryHive.currentUser,
//     path:
//         r'Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice',
//   );
//   var progId = key.getValueAsString('ProgId');
//   if (progId == null) {
//     throw Exception('Could not determine default browser');
//   }

//   return progId.toLowerCase();
// }

// String? defaultBrowser() {
//   String? browser;
//   if (Platform.isWindows) {
//     browser = _defaultBrowserWin();
//   } else {
//     log('Default browser feature not supported on this OS');
//     return null;
//   }

//   var allBrowsers = getBrowsers();
//   // for (var b in allBrowsers) {

//   // }
//   return null;
// }

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

extension Uint8ListBlobConversionX on Uint8List {
  /// Alternative to [allocatePointer] from win32, which accepts an allocator
  Pointer<Uint8> allocatePointerWith(Allocator allocator) {
    final blob = allocator<Uint8>(length);
    blob.asTypedList(length).setAll(0, this);
    return blob;
  }
}
