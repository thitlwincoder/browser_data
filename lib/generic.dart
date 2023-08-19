// ignore_for_file: public_member_api_docs, sort_constructors_first
// String _paths() {}

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:file_copy/file_copy.dart';
import 'package:path/path.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

import 'model.dart';

abstract class Browser {
  final String? name;

  final bool profileSupport;

  final List<String>? aliases;

  final List<String> profileDirPrefixes;

  final String? macPath;
  final String? linuxPath;
  final String? windowsPath;

  final String historySQL;
  final String historyFile;

  final String? bookmarksFile;

  String? historyDir;

  final String? sqlite3Path;

  Browser({
    required this.name,
    required this.profileSupport,
    this.aliases,
    this.profileDirPrefixes = const [],
    this.macPath,
    this.linuxPath,
    this.windowsPath,
    required this.historySQL,
    required this.historyFile,
    this.bookmarksFile,
    this.historyDir,
    this.sqlite3Path,
  }) {
    if (sqlite3Path != null) {
      open.overrideForAll(() => DynamicLibrary.open(sqlite3Path!));
    }

    Map<String, String> envVars = Platform.environment;
    if (Platform.isWindows) {
      var homedir = envVars['UserProfile']!;
      historyDir = join(homedir, windowsPath);
    } else if (Platform.isMacOS) {
      var homedir = envVars['HOME']!;
      historyDir = join(homedir, macPath);
    } else if (Platform.isLinux) {
      var homedir = envVars['HOME']!;
      historyDir = join(homedir, linuxPath);
    } else {
      throw Exception('Platform Not Supported');
    }

    if (profileSupport && profileDirPrefixes.isEmpty) {
      profileDirPrefixes.add('*');
    }
  }

  Bookmark bookmarksParser(String bookmarkPath);

  List<String> profiles({required String profileFile}) {
    if (!Directory(historyDir!).existsSync()) {
      print('$name browser is not installed');
      return [];
    }

    if (!profileSupport) return ['.'];

    List<String> profileDirs = [];

    var files = Directory(historyDir!).listSync(recursive: true);

    for (var item in files) {
      if (basename(item.path) == profileFile) {
        profileDirs.add(basename(item.parent.path));
      }
    }
    return profileDirs;
  }

  String historyPathProfile({required String profileDir}) {
    return '$historyDir/$profileDir/$historyFile';
  }

  String bookmarkPathProfile({required String profileDir}) {
    return '$historyDir/$profileDir/$bookmarksFile';
  }

  List<String> paths({required String profileFile}) {
    return [
      for (var profileDir in profiles(profileFile: profileFile))
        join(historyDir!, profileDir, profileFile)
    ];
  }

  // Future<void> historyProfiles({required List<String> profileDirs}) {
  //   var historyPaths = [
  //     for (var profileDir in profileDirs)
  //       historyPathProfile(profileDir: profileDir),
  //   ];
  //   return fetchHistory(historyPaths: historyPaths);
  // }

  Future<List<History>> fetchHistory({
    List<String>? historyPaths,
    bool sort = true,
    bool desc = false,
  }) async {
    historyPaths ??= paths(profileFile: historyFile);

    List<History> histories = [];

    for (var historyPath in historyPaths) {
      var dir = Directory.systemTemp.createTempSync();
      var f = File("${dir.path}/$historyFile");
      await f.create();
      String tmpFile = f.path;

      await FileCopy.copyFile(File(historyPath), tmpFile);

      var conn =
          sqlite3.open('file:$tmpFile?mode=ro&immutable=1&nolock=1', uri: true);
      var result = conn.select(historySQL);
      for (var e in result) {
        histories.add(History.fromJson(e));
      }
      conn.dispose();
    }

    return histories;
  }

  Future<Bookmark?> fetchBookmarks({
    bool sort = true,
    bool desc = false,
  }) async {
    assert(
      bookmarksFile != null,
      "Bookmarks are not supported for $name browser",
    );
    var bookmarkPaths = paths(profileFile: bookmarksFile!);

    for (var bookmarkPath in bookmarkPaths) {
      var dir = Directory.systemTemp.createTempSync();
      var f = File("${dir.path}/$bookmarksFile");
      await f.create();
      String tmpFile = f.path;

      var isExists = await File(bookmarkPath).exists();
      if (!isExists) return null;

      await FileCopy.copyFile(File(bookmarkPath), tmpFile);

      return bookmarksParser(tmpFile);
    }
    return null;
  }
}

class ChromiumBasedBrowser extends Browser {
  ChromiumBasedBrowser({
    required String name,
    String? macPath,
    String? linuxPath,
    required String? windowsPath,
    String? sqlite3Path,
    required List<String>? aliases,
    required bool profileSupport,
  }) : super(
          name: name,
          aliases: aliases,
          macPath: macPath,
          linuxPath: linuxPath,
          windowsPath: windowsPath,
          sqlite3Path: sqlite3Path,
          profileSupport: profileSupport,
          historyFile: 'History',
          bookmarksFile: 'Bookmarks',
          profileDirPrefixes: ["Default*", "Profile*"],
          historySQL: """
            SELECT
                datetime(
                    visits.visit_time/1000000-11644473600, 'unixepoch', 'localtime'
                ) as 'visit_time',
                 datetime(
                    urls.last_visit_time/1000000-11644473600, 'unixepoch', 'localtime'
                ) as 'last_visit_time',
                urls.url,
                urls.title,
                visits.visit_duration,
                urls.visit_count
            FROM
                visits INNER JOIN urls ON visits.url = urls.id
            WHERE
                visits.visit_duration > 0
            ORDER BY
                visit_time DESC
            LIMIT 20
        """,
        );

  @override
  Bookmark bookmarksParser(String bookmarkPath) {
    var bm = jsonDecode(File(bookmarkPath).readAsStringSync());
    return Bookmark.fromJson(bm['roots']);
  }
}
