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
  String get name;

  String? macPath;
  String? linuxPath;
  String? windowsPath;

  bool get profileSupport;

  List<String>? aliases;

  final List<String>? profileDirPrefixes;

  String get historyFile;

  String? bookmarksFile;

  String? historyDir;

  final String? sqlite3Path;

  Browser({
    this.profileDirPrefixes,
    this.historyDir,
    this.sqlite3Path,
  }) {
    if (sqlite3Path != null) {
      open.overrideForAll(() => DynamicLibrary.open(sqlite3Path!));
    }

    Map<String, String> envVars = Platform.environment;
    if (Platform.isWindows) {
      assert(windowsPath != null);

      var homedir = envVars['UserProfile']!;
      historyDir = join(homedir, windowsPath);
    } else if (Platform.isMacOS) {
      assert(macPath != null);

      var homedir = envVars['HOME']!;
      historyDir = join(homedir, macPath);
    } else if (Platform.isLinux) {
      assert(linuxPath != null);

      var homedir = envVars['HOME']!;
      historyDir = join(homedir, linuxPath);
    } else {
      throw UnimplementedError();
    }

    var prefixes = profileDirPrefixes ?? [];

    if (profileSupport && prefixes.isEmpty) {
      prefixes.add('*');
    }
  }

  Bookmark bookmarksParser(String bookmarkPath);

  String historySQL({int limit = 20});

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

  Future<void> historyProfiles({required List<String> profileDirs}) {
    var historyPaths = [
      for (var profileDir in profileDirs)
        historyPathProfile(profileDir: profileDir),
    ];
    return fetchHistory(historyPaths: historyPaths);
  }

  Future<List<History>> fetchHistory({
    List<String>? historyPaths,
    int limit = 20,
  }) async {
    historyPaths ??= paths(profileFile: historyFile);

    List<History> histories = [];

    for (var historyPath in historyPaths) {
      var size = await File(historyPath).length();
      if (size == 0) continue;

      var dir = await Directory.systemTemp.createTemp();
      var f = File("${dir.path}/$historyFile");
      await f.create();
      String tmpFile = f.path;

      await FileCopy.copyFile(File(historyPath), tmpFile);

      var conn =
          sqlite3.open('file:$tmpFile?mode=ro&immutable=1&nolock=1', uri: true);
      var result = conn.select(historySQL(limit: limit));
      for (var e in result) {
        histories.add(History.fromJson(e));
      }
      conn.dispose();
    }

    return histories;
  }

  Future<Bookmark?> fetchBookmarks() async {
    assert(
      bookmarksFile != null,
      "Bookmarks are not supported for $name browser",
    );

    var bookmarkPaths = paths(profileFile: bookmarksFile!);

    for (var bookmarkPath in bookmarkPaths) {
      var file = File(bookmarkPath);

      var isExists = await file.exists();
      if (!isExists) continue;

      var size = await file.length();
      if (size == 0) continue;

      var dir = Directory.systemTemp.createTempSync();
      var f = File("${dir.path}/$bookmarksFile");
      await f.create();
      String tmpFile = f.path;

      await FileCopy.copyFile(File(bookmarkPath), tmpFile);

      return bookmarksParser(tmpFile);
    }
    return null;
  }
}

abstract class ChromiumBasedBrowser extends Browser {
  ChromiumBasedBrowser({
    String? sqlite3Path,
  }) : super(
          sqlite3Path: sqlite3Path,
          profileDirPrefixes: ["Default*", "Profile*"],
        );

  @override
  String get historyFile => 'History';

  @override
  String? get bookmarksFile => 'Bookmarks';

  @override
  Bookmark bookmarksParser(String bookmarkPath) {
    var bm = jsonDecode(File(bookmarkPath).readAsStringSync());
    return Bookmark.fromJson(bm['roots']);
  }

  @override
  String historySQL({int limit = 20}) {
    return """
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
            LIMIT $limit
        """;
  }
}
