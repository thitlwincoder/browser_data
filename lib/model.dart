import 'dart:convert';

History historyFromJson(String str) => History.fromJson(json.decode(str));

String historyToJson(History data) => json.encode(data.toJson());

class History {
  final String url;
  final DateTime? visitTime;
  final int? visitDuration;
  final String title;
  final int? visitCount;
  final DateTime? lastVisitTime;

  History({
    required this.url,
    this.visitTime,
    this.visitDuration,
    required this.title,
    this.visitCount,
    this.lastVisitTime,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
        url: json["url"],
        visitTime: DateTime.parse(json["visit_time"]),
        visitDuration: json["visit_duration"],
        title: json["title"],
        visitCount: json["visit_count"],
        lastVisitTime: DateTime.parse(json["last_visit_time"]),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "visit_time": visitTime.toString(),
        "visit_duration": visitDuration,
        "title": title,
        "visit_count": visitCount,
        "last_visit_time": lastVisitTime.toString(),
      };
}

enum Type {
  folder,
  url;

  factory Type.from(String type) {
    if (type == 'folder') return folder;
    return url;
  }
}

class Bookmark {
  final BookmarkData bookmarkBar;
  final BookmarkData other;
  final BookmarkData synced;

  Bookmark({
    required this.bookmarkBar,
    required this.other,
    required this.synced,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        bookmarkBar: BookmarkData.fromJson(json["bookmark_bar"]),
        other: BookmarkData.fromJson(json["other"]),
        synced: BookmarkData.fromJson(json["synced"]),
      );

  Map<String, dynamic> toJson() => {
        "bookmark_bar": bookmarkBar.toJson(),
        "other": other.toJson(),
        "synced": synced.toJson(),
      };
}

class BookmarkData {
  final String name;
  final Type type;
  final String? url;
  final DateTime dateAdded;
  final DateTime dateLastUsed;
  final List<BookmarkData>? children;

  BookmarkData({
    required this.name,
    required this.type,
    required this.url,
    required this.dateAdded,
    required this.dateLastUsed,
    required this.children,
  });

  factory BookmarkData.fromJson(Map<String, dynamic> json) => BookmarkData(
        name: json["name"],
        type: Type.from(json["type"]),
        url: json["url"],
        dateAdded:
            DateTime.fromMicrosecondsSinceEpoch(int.parse(json["date_added"])),
        dateLastUsed: DateTime.fromMicrosecondsSinceEpoch(
            int.parse(json["date_last_used"])),
        children: json["children"] == null
            ? null
            : List<BookmarkData>.from(
                json["children"]!.map((x) => BookmarkData.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "type": type.name,
        "url": url,
        "date_added": dateAdded.toString(),
        "date_last_used": dateLastUsed.toString(),
        "children": children?.map((x) => x.toJson()).toList(),
      };
}
