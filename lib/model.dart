import 'dart:convert';

import 'package:browser_data/browser_data.dart';

History historyFromJson(String str) => History.fromJson(json.decode(str));

String historyToJson(History data) => json.encode(data.toJson());

class History {
  final String url;
  final DateTime? visitTime;
  final String title;

  History({
    required this.url,
    this.visitTime,
    required this.title,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
        url: json['url'],
        title: json['title'],
        visitTime: DateTime.parse(json['visit_time']),
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'visit_time': visitTime.toString(),
      };
}

class Bookmark {
  final String? url;
  final String name;
  final DateTime date;
  final String folder;

  Bookmark({
    required this.url,
    required this.name,
    required this.date,
    required this.folder,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        url: json['url'],
        name: json['name'],
        folder: json['folder'],
        date: dateParse(json['date']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'folder': folder,
        'date': date.toString(),
      };
}

// List<Download> downloadFromJson(String str) =>
//     List<Download>.from(json.decode(str).map((x) => Download.fromJson(x)));

// String downloadToJson(List<Download> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class Download {
//   final String targetPath;
//   final DateTime startTime;
//   final int receivedBytes;
//   final int totalBytes;
//   final DateTime endTime;
//   final String tabUrl;
//   final String originalMimeType;

//   Download({
//     required this.targetPath,
//     required this.startTime,
//     required this.receivedBytes,
//     required this.totalBytes,
//     required this.endTime,
//     required this.tabUrl,
//     required this.originalMimeType,
//   });

//   factory Download.fromJson(Map<String, dynamic> json) => Download(
//         targetPath: json['target_path'],
//         startTime: DateTime.fromMicrosecondsSinceEpoch(json['start_time']),
//         receivedBytes: json['received_bytes'],
//         totalBytes: json['total_bytes'],
//         endTime: DateTime.fromMicrosecondsSinceEpoch(json['end_time']),
//         tabUrl: json['tab_url'],
//         originalMimeType: json['original_mime_type'],
//       );

//   Map<String, dynamic> toJson() => {
//         'target_path': targetPath,
//         'start_time': startTime.toString(),
//         'received_bytes': receivedBytes,
//         'total_bytes': totalBytes,
//         'end_time': endTime.toString(),
//         'tab_url': tabUrl,
//         'original_mime_type': originalMimeType,
//       };
// }

class Password {
  final String url;
  final String username;
  final String password;

  Password({
    required this.url,
    required this.username,
    required this.password,
  });

  factory Password.fromJson(Map<String, dynamic> json) => Password(
        url: json['url'],
        username: json['username'],
        password: json['password'],
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'username': username,
        'password': password,
      };
}
