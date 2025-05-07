import 'package:sqlite3/sqlite3.dart';

import 'generic.dart';
import 'model.dart';

class Chromium extends ChromiumBasedBrowser {
  Chromium({super.sqlite3Path});

  @override
  String get name => 'Chromium';

  @override
  bool get profileSupport => true;

  @override
  String? get linuxPath => '.config/chromium';

  @override
  String? get windowsPath => 'AppData/Local/chromium/User Data';

  @override
  List<String>? get aliases {
    return ['chromiumhtm', 'chromium-browser', 'chromiumhtml'];
  }
}

class Chrome extends ChromiumBasedBrowser {
  Chrome({super.sqlite3Path});

  @override
  String get name => 'Chrome';

  @override
  bool get profileSupport => true;

  @override
  String? get linuxPath => '.config/google-chrome';

  @override
  String? get macPath => 'Library/Application Support/Google/Chrome/';

  @override
  String? get windowsPath => 'AppData/Local/Google/Chrome/User Data';

  @override
  List<String>? get aliases {
    return ['chromehtml', 'google-chrome', 'chromehtm'];
  }
}

class Firefox extends Browser {
  Firefox({super.sqlite3Path});

  @override
  String get name => 'Firefox';

  @override
  bool get profileSupport => true;

  @override
  List<String>? get aliases => ['firefoxurl'];

  @override
  String get historyFile => 'places.sqlite';

  @override
  String? get bookmarksFile => 'places.sqlite';

  @override
  String? get linuxPath => '.mozilla/firefox';

  @override
  String? get windowsPath => 'AppData/Roaming/Mozilla/Firefox/Profiles';

  @override
  String? get macPath => 'Library/Application Support/Firefox/Profiles/';

  @override
  String get historySQL => """
        SELECT
            datetime(
                visit_date/1000000, 'unixepoch', 'localtime'
            ) AS 'visit_time',
            url,
            moz_places.title
        FROM
            moz_historyvisits
        INNER JOIN
            moz_places
        ON
            moz_historyvisits.place_id = moz_places.id
        WHERE
            visit_date IS NOT NULL AND url LIKE 'http%' AND title IS NOT NULL
        ORDER BY
            visit_time DESC
        LIMIT (?) OFFSET (?);
    """;

  @override
  List<Bookmark> bookmarksParser(String bookmarkPath) {
    var bookmarkSQL = """
            SELECT
                datetime(
                    moz_bookmarks.dateAdded/1000000,'unixepoch','localtime'
                ) AS added_time,
                url,
                moz_bookmarks.title,
                moz_folder.title
            FROM
                moz_bookmarks JOIN moz_places, moz_bookmarks as moz_folder
            ON
                moz_bookmarks.fk = moz_places.id
                AND moz_bookmarks.parent = moz_folder.id
            WHERE
                moz_bookmarks.dateAdded IS NOT NULL AND url LIKE 'http%'
                AND moz_bookmarks.title IS NOT NULL
       """;

    var conn = sqlite3.open('file:$bookmarkPath?mode=ro', uri: true);
    var result = conn.select(bookmarkSQL);

    var bookmarks = <Bookmark>[];

    for (var e in result) {
      bookmarks.add(
        Bookmark(
          url: e['url'],
          name: e['title'],
          folder: e['folder'],
          date: DateTime.fromMicrosecondsSinceEpoch(int.parse(e['d'])),
        ),
      );
    }
    conn.dispose();

    return bookmarks;
  }
}

class LibreWolf extends Firefox {
  LibreWolf({super.sqlite3Path});

  @override
  String get name => 'LibreWolf';

  @override
  String? get linuxPath => '.librewolf';

  @override
  List<String>? get aliases => ['librewolfurl'];
}

class Safari extends Browser {
  Safari({super.sqlite3Path});

  @override
  String get name => 'Safari';

  @override
  bool get profileSupport => false;

  @override
  String? get macPath => 'Library/Safari';

  @override
  String get historyFile => 'History.db';

  @override
  String get historySQL => """
        SELECT
            datetime(
                visit_time + 978307200, 'unixepoch', 'localtime'
            ) as visit_time,
            url,
            title
        FROM
            history_visits
        INNER JOIN
            history_items
        ON
            history_items.id = history_visits.history_item
        ORDER BY
            visit_time DESC
        LIMIT (?) OFFSET (?);
    """;

  @override
  List<Bookmark> bookmarksParser(String bookmarkPath) {
    return [];
  }
}

class Edge extends ChromiumBasedBrowser {
  Edge({super.sqlite3Path});

  @override
  String get name => 'Edge';

  @override
  bool get profileSupport => true;

  @override
  String? get linuxPath => '.config/microsoft-edge-dev';

  @override
  String? get macPath => 'Library/Application Support/Microsoft Edge';

  @override
  String? get windowsPath => 'AppData/Local/Microsoft/Edge/User Data';

  @override
  List<String>? get aliases {
    return ['msedgehtm', 'msedge', 'microsoft-edge', 'microsoft-edge-dev'];
  }
}

class Opera extends ChromiumBasedBrowser {
  Opera({super.sqlite3Path});

  @override
  String get name => 'Opera';

  @override
  bool get profileSupport => false;

  @override
  String? get linuxPath => '.config/opera';

  @override
  String? get windowsPath => 'AppData/Roaming/Opera Software/Opera Stable';

  @override
  String? get macPath => 'Library/Application Support/com.operasoftware.Opera';
}

class OperaGX extends ChromiumBasedBrowser {
  OperaGX({super.sqlite3Path});

  @override
  String get name => 'OperaGX';

  @override
  bool get profileSupport => false;

  @override
  String? get windowsPath => 'AppData/Roaming/Opera Software/Opera GX Stable';

  @override
  List<String>? get aliases => ['operagxstable', 'operagx-stable'];
}

class Brave extends ChromiumBasedBrowser {
  Brave({super.sqlite3Path});

  @override
  String get name => 'Brave';

  @override
  bool get profileSupport => true;

  @override
  String? get linuxPath => '.config/BraveSoftware/Brave-Browser';

  @override
  String? get macPath {
    return 'Library/Application Support/BraveSoftware/Brave-Browser';
  }

  @override
  String? get windowsPath {
    return 'AppData/Local/BraveSoftware/Brave-Browser/User Data';
  }

  @override
  List<String>? get aliases => ['bravehtml'];
}

class Vivaldi extends ChromiumBasedBrowser {
  Vivaldi({super.sqlite3Path});

  @override
  String get name => 'Vivaldi';

  @override
  bool get profileSupport => true;

  @override
  String? get linuxPath => '.config/vivaldi';

  @override
  String? get macPath => 'Library/Application Support/Vivaldi';

  @override
  String? get windowsPath => 'AppData/Local/Vivaldi/User Data';

  @override
  List<String>? get aliases => ['vivaldi-stable', 'vivaldistable'];
}

class Epic extends ChromiumBasedBrowser {
  Epic({super.sqlite3Path});

  @override
  String get name => 'Epic Privacy Browser';

  @override
  bool get profileSupport => false;

  @override
  String? get windowsPath => 'AppData/Local/Epic Privacy Browser/User Data';

  @override
  String? get macPath => 'Library/Application Support/HiddenReflex/Epic';
}

class Avast extends ChromiumBasedBrowser {
  Avast({super.sqlite3Path});

  @override
  String get name => 'Avast Secure Browser';

  @override
  bool get profileSupport => false;

  @override
  String? get windowsPath => 'AppData/Local/AVAST Software/Browser/User Data';
}

class Torch extends ChromiumBasedBrowser {
  Torch({super.sqlite3Path});

  @override
  String get name => 'Torch';

  @override
  bool get profileSupport => false;

  @override
  String? get windowsPath => 'AppData/Local/Torch/User Data';
}

class Orbitum extends ChromiumBasedBrowser {
  Orbitum({super.sqlite3Path});

  @override
  String get name => 'Orbitum';

  @override
  bool get profileSupport => false;

  @override
  String? get windowsPath => 'AppData/Local/Orbitum/User Data';
}

class CentBrowser extends ChromiumBasedBrowser {
  CentBrowser({super.sqlite3Path});

  @override
  String get name => 'CentBrowser';

  @override
  bool get profileSupport => false;

  @override
  String? get windowsPath => 'AppData/Local/CentBrowser/User Data';
}

class Yandex extends ChromiumBasedBrowser {
  Yandex({super.sqlite3Path});

  @override
  String get name => 'Yandex Browser';

  @override
  bool get profileSupport => false;

  @override
  String? get windowsPath => 'AppData/Local/Yandex/YandexBrowser/User Data';
}
