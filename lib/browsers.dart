import 'package:browser_data/model.dart';

import 'generic.dart';

class Chromium extends ChromiumBasedBrowser {
  Chromium({super.sqlite3Path})
      : super(
          name: 'Chromium',
          profileSupport: true,
          linuxPath: '.config/chromium',
          windowsPath: r'AppData\Local\chromium\User Data',
          aliases: ["chromiumhtm", "chromium-browser", "chromiumhtml"],
        );
}

class Chrome extends ChromiumBasedBrowser {
  Chrome({super.sqlite3Path})
      : super(
          name: 'Chrome',
          profileSupport: true,
          linuxPath: '.config/google-chrome',
          macPath: 'Library/Application Support/Google/Chrome/',
          windowsPath: r'AppData\Local\Google\Chrome\User Data',
          aliases: ["chromehtml", "google-chrome", "chromehtm"],
        );
}

class Firefox extends Browser {
  Firefox({
    String? name,
    String? linuxPath,
    List<String>? aliases,
    super.sqlite3Path,
  }) : super(
          name: name ?? 'Firefox',
          profileSupport: true,
          aliases: aliases ?? ['firefoxurl'],
          historyFile: 'places.sqlite',
          bookmarksFile: 'places.sqlite',
          linuxPath: linuxPath ?? '.mozilla/firefox',
          windowsPath: 'AppData/Roaming/Mozilla/Firefox/Profiles',
          macPath: 'Library/Application Support/Firefox/Profiles/',
        );

  // @override
  // Bookmark bookmarksParser(String bookmarkPath) {
  //   var bookmarkSQL = """
  //           SELECT
  //               datetime(
  //                   moz_bookmarks.dateAdded/1000000,'unixepoch','localtime'
  //               ) AS added_time,
  //               url, moz_bookmarks.title, moz_folder.title
  //           FROM
  //               moz_bookmarks JOIN moz_places, moz_bookmarks as moz_folder
  //           ON
  //               moz_bookmarks.fk = moz_places.id
  //               AND moz_bookmarks.parent = moz_folder.id
  //           WHERE
  //               moz_bookmarks.dateAdded IS NOT NULL AND url LIKE 'http%'
  //               AND moz_bookmarks.title IS NOT NULL
  //      """;

  //   var conn = sqlite3.open('file:$bookmarkPath?mode=ro', uri: true);
  //   var result = conn.select(bookmarkSQL);

  //   throw UnimplementedError();
  //   // for (var e in result) {
  //   //   bookmarks.add(Bookmark.fromJson(e));
  //   // }
  //   // conn.dispose();

  //   // return Bookmark(bookmarkBar: bookmarkBar, other: other, synced: synced);
  // }

  @override
  String historySQL({int limit = 20}) {
    return """
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
        LIMIT $limit
    """;
  }

  @override
  Bookmark bookmarksParser(String bookmarkPath) {
    throw UnimplementedError();
  }
}

class LibreWolf extends Firefox {
  LibreWolf({super.sqlite3Path})
      : super(
          name: 'LibreWolf',
          linuxPath: '.librewolf',
          aliases: ['librewolfurl'],
        );
}

class Safari extends Browser {
  Safari({super.sqlite3Path})
      : super(
          name: 'Safari',
          macPath: 'Library/Safari',
          profileSupport: false,
          historyFile: 'History.db',
        );

  @override
  Bookmark bookmarksParser(String bookmarkPath) {
    throw UnimplementedError();
  }

  @override
  String historySQL({
    int limit = 20,
  }) {
    return """
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
        LIMIT $limit
    """;
  }
}

class Edge extends ChromiumBasedBrowser {
  Edge({super.sqlite3Path})
      : super(
          name: 'Edge',
          profileSupport: true,
          linuxPath: ".config/microsoft-edge-dev",
          windowsPath: r"AppData\Local\Microsoft\Edge\User Data",
          macPath: "Library/Application Support/Microsoft Edge",
          aliases: [
            "msedgehtm",
            "msedge",
            "microsoft-edge",
            "microsoft-edge-dev"
          ],
        );
}

class Opera extends ChromiumBasedBrowser {
  Opera({super.sqlite3Path})
      : super(
          name: 'Opera',
          profileSupport: false,
          linuxPath: ".config/opera",
          aliases: ["operastable", "opera-stable"],
          windowsPath: r"AppData\Roaming\Opera Software\Opera Stable",
          macPath: "Library/Application Support/com.operasoftware.Opera",
        );
}

class OperaGX extends ChromiumBasedBrowser {
  OperaGX({super.sqlite3Path})
      : super(
          name: 'OperaGX',
          profileSupport: false,
          aliases: ["operagxstable", "operagx-stable"],
          windowsPath: r"AppData\Roaming\Opera Software\Opera GX Stable",
        );
}

class Brave extends ChromiumBasedBrowser {
  Brave({super.sqlite3Path})
      : super(
          name: 'Brave',
          profileSupport: true,
          aliases: ["bravehtml"],
          linuxPath: ".config/BraveSoftware/Brave-Browser",
          macPath: "Library/Application Support/BraveSoftware/Brave-Browser",
          windowsPath: r"AppData\Local\BraveSoftware\Brave-Browser\User Data",
        );
}

class Vivaldi extends ChromiumBasedBrowser {
  Vivaldi({super.sqlite3Path})
      : super(
          name: 'Vivaldi',
          profileSupport: true,
          aliases: ["vivaldi-stable", "vivaldistable"],
          linuxPath: ".config/vivaldi",
          macPath: "Library/Application Support/Vivaldi",
          windowsPath: r"AppData\Local\Vivaldi\User Data",
        );
}
