import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:browser_data/browser_data.dart';
import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

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

  List<Bookmark> bookmarksParser(String bookmarkPath);

  String get historySQL;

  List<String> _getProfiles({required String profileFile}) {
    if (!Directory(historyDir!).existsSync()) {
      print('$name browser is not installed');
      return [];
    }

    if (!profileSupport) return ['.'];

    List<String> profileDirs = [];

    try {
      var files = Directory(historyDir!).listSync(recursive: true);

      for (var item in files) {
        if (basename(item.path) == profileFile) {
          profileDirs.add(basename(item.parent.path));
        }
      }
    } catch (e) {
      var files = Directory(historyDir!).listSync();

      for (var e in files) {
        if (e is File) continue;

        var files = Directory(e.path).listSync();
        for (var item in files) {
          if (basename(item.path) == profileFile) {
            profileDirs.add(basename(item.parent.path));
          }
        }
      }
    }

    return profileDirs;
  }

  // String historyPathProfile({required String profileDir}) {
  //   return join(historyDir!, profileDir, historyFile);
  // }

  // String bookmarkPathProfile({required String profileDir}) {
  //   return join(historyDir!, profileDir, bookmarksFile);
  // }

  List<String> paths({required String profileFile, List<String>? profiles}) {
    profiles ??= _getProfiles(profileFile: profileFile);

    return [
      for (var profile in profiles) join(historyDir!, profile, profileFile)
    ];
  }

  // Future<void> historyProfiles({required List<String> profileDirs}) {
  //   var historyPaths = [
  //     for (var profileDir in profileDirs)
  //       historyPathProfile(profileDir: profileDir),
  //   ];
  //   return fetchHistory(profiles: historyPaths);
  // }

  List<String> fetchProfiles() {
    return _getProfiles(profileFile: historyFile);
  }

  Future<List<History>> fetchHistory({List<String>? profiles}) async {
    var historyPaths = paths(profileFile: historyFile, profiles: profiles);

    List<History> histories = [];

    for (var historyPath in historyPaths) {
      var size = await File(historyPath).length();
      if (size == 0) continue;

      var dir = await Directory.systemTemp.createTemp();
      var f = File('${dir.path}/$historyFile');
      await f.create();
      String tmpFile = f.path;

      await copyFile(File(historyPath), tmpFile);

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

  Future<List<Bookmark>?> fetchBookmarks({List<String>? profiles}) async {
    assert(
      bookmarksFile != null,
      'Bookmarks are not supported for $name browser',
    );

    var bookmarkPaths = paths(profileFile: bookmarksFile!, profiles: profiles);

    for (var bookmarkPath in bookmarkPaths) {
      var file = File(bookmarkPath);

      var isExists = await file.exists();
      if (!isExists) continue;

      var size = await file.length();
      if (size == 0) continue;

      var dir = Directory.systemTemp.createTempSync();
      var f = File('${dir.path}/$bookmarksFile');
      await f.create();
      String tmpFile = f.path;

      await copyFile(File(bookmarkPath), tmpFile);

      return bookmarksParser(tmpFile);
    }
    return null;
  }

  Future<Uint8List?>? _getMasterKey() {
    if (historyDir == null) return null;

    var f = File(join(historyDir!, 'Local State'));
    if (!f.existsSync()) return null;

    var localState = jsonDecode(f.readAsStringSync());

    var key = base64Decode(localState['os_crypt']['encrypted_key']);
    key = key.sublist(5);

    return cryptUnprotectData(key);
  }

  Future<List<Password>?> fetchPasswords({List<String>? profiles}) async {
    var key = await _getMasterKey();

    if (key == null) return null;

    List<Password> passwords = [];

    var _paths = paths(profileFile: 'Login Data', profiles: profiles);

    for (var p in _paths) {
      var size = await File(p).length();
      if (size == 0) continue;

      var dir = await Directory.systemTemp.createTemp();
      var f = File('${dir.path}/Login Data');
      await f.create();
      String tmpFile = f.path;

      await copyFile(File(p), tmpFile);

      var conn =
          sqlite3.open('file:$tmpFile?mode=ro&immutable=1&nolock=1', uri: true);
      var result = conn.select(
          'SELECT action_url, username_value, password_value FROM logins');

      for (var e in result) {
        var url = '${e['action_url']}';
        var name = '${e['username_value']}';
        var password = e['password_value'];
        var pass = _decryptPassword(password, key);

        if (url.isEmpty || name.isEmpty) continue;

        passwords.add(Password(url: url, username: name, password: pass));
      }
    }

    return passwords;
  }

  String _decryptPassword(Uint8List buff, Uint8List key) {
    var iv = buff.sublist(3, 15);
    var payload = buff.sublist(15);

    var encrypter = Encrypter(AES(Key(key), mode: AESMode.gcm));
    var decryptedPass = encrypter.decrypt(Encrypted(payload), iv: IV(iv));
    return decryptedPass;
  }
}

abstract class ChromiumBasedBrowser extends Browser {
  ChromiumBasedBrowser({
    super.sqlite3Path,
  }) : super(
          profileDirPrefixes: ['Default*', 'Profile*'],
        );

  @override
  String get historyFile => 'History';

  @override
  String? get bookmarksFile => 'Bookmarks';

  @override
  List<Bookmark> bookmarksParser(String bookmarkPath) {
    List<Bookmark> _deeper(
      Map<String, dynamic> json,
      String folder,
      List<Bookmark> bookmarksList,
    ) {
      for (var node in json.keys) {
        if (node == 'children') {
          for (var child in json[node]) {
            if (child['type'] == 'url') {
              bookmarksList.add(Bookmark(
                folder: folder,
                url: child['url'],
                name: child['name'],
                date: dateParse(child['date_added']),
              ));
            } else if (child['type'] == 'folder') {
              bookmarksList =
                  _deeper(child, join(folder, child['name']), bookmarksList);
            }
          }
          break;
        } else {
          bookmarksList = _deeper(json[node], folder, bookmarksList);
        }
      }
      return bookmarksList;
    }

    Map<String, dynamic> bm = jsonDecode(File(bookmarkPath).readAsStringSync());

    List<Bookmark> bookmarksList = [];

    Map<String, dynamic> roots = bm['roots'];

    for (var root in roots.keys) {
      if (roots[root] is Map) {
        bookmarksList = _deeper(roots[root], root, bookmarksList);
      }
    }

    return bookmarksList;
  }

  @override
  String get historySQL {
    return """
           SELECT
                datetime(
                    visits.visit_time/1000000-11644473600, 'unixepoch', 'localtime'
                ) as 'visit_time',
                urls.url,
                urls.title
            FROM
                visits INNER JOIN urls ON visits.url = urls.id
            WHERE
                visits.visit_duration > 0
            ORDER BY
                visit_time DESC
        """;
  }
}
