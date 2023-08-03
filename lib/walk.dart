import 'dart:io';

void walk(String dirPath) {
  var dir = Directory(dirPath).listSync();
  for (var e in dir) {
  }
}
