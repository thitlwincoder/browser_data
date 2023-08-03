// ignore_for_file: public_member_api_docs, sort_constructors_first
// String _paths() {}

import 'dart:io';

import 'package:file/memory.dart';
import 'package:file_copy/file_copy.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

import 'model.dart';

class Browser {
  final String? androidPath;
  final String? windowsPath;

  final bool profileSupport;
  final List<String> profileDirPrefixes;
  final String? bookmarksFile;
  String? historyDir;
  final List<String>? aliases;
  final String? name;
  final String historyFile;
  final String historySQL;

  Browser({
    this.androidPath,
    this.windowsPath,
    this.profileSupport = false,
    this.profileDirPrefixes = const [],
    this.bookmarksFile,
    this.historyDir,
    this.aliases,
    this.name,
    required this.historyFile,
    required this.historySQL,
  }) {
    if (Platform.isWindows) {
      var homedir = Platform.environment['UserProfile']!;
      historyDir = join(homedir, windowsPath);
    } else if (Platform.isAndroid) {
      historyDir = androidPath;
    } else {
      throw Exception('Platform Not Supported');
    }

    if (profileSupport && profileDirPrefixes.isEmpty) {
      profileDirPrefixes.add('*');
    }
  }

  // List<String> profiles({required String profileFile}) {
  //   if (!Directory(historyDir!).existsSync()) {
  //     print('$name browser is not installed');
  //     return [];
  //   }

  //   if (!profileSupport) return ['.'];

  //   List<String> profileDirs = [];

  //   var files = Directory(historyDir!).listSync();

  //   files = Directory(files[0].path).listSync();
  //   files = Directory(files[0].path).listSync();

  //   for (var item in files) {
  //     print(basename(item.path));
  //     // if (basename(item.path) == profileFile) {
  //     //   var path = historyDir!;
  //     //   profileDirs.add(path);
  //     // }
  //   }
  //   return profileDirs;
  // }

  String historyPathProfile({required String profileDir}) {
    return '$historyDir/$profileDir/$historyFile';
  }

  List<String> paths({required String profileFile}) {
    return [
      // for (var profileDir in profiles(profileFile: profileFile))
      join(historyDir!, 'Default', profileFile)
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
    bool sort = true,
    bool desc = false,
  }) async {
    historyPaths ??= paths(profileFile: historyFile);
    var tmpDir = MemoryFileSystem().file(historyFile);
    List<History> histories = [];
    for (var historyPath in historyPaths) {
      await FileCopy.copyFile(File(historyPath), tmpDir.path);

      var conn = sqlite3
          .open('file:${tmpDir.path}?mode=ro&immutable=1&nolock=1', uri: true);
      var result = conn.select(historySQL);
      for (var e in result) {
        histories.add(History.fromJson(e));
      }
      conn.dispose();
    }
    return histories;
  }
}

class ChromiumBasedBrowser extends Browser {
  ChromiumBasedBrowser({
    String? name,
    String? androidPath,
    String? windowsPath,
    List<String>? aliases,
    bool profileSupport = false,
  }) : super(
          name: name,
          aliases: aliases,
          profileSupport: profileSupport,
          androidPath: androidPath,
          windowsPath: windowsPath,
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
            LIMIT 1
        """,
        );

  void bookmarksParser(String bookmarkPath) {
    var bp = File(bookmarkPath).readAsStringSync();
    print(bp);
  }
}
