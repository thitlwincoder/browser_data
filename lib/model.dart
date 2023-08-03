// To parse this JSON data, do
//
//     final history = historyFromJson(jsonString);

import 'dart:convert';

History historyFromJson(String str) => History.fromJson(json.decode(str));

String historyToJson(History data) => json.encode(data.toJson());

class History {
  final String? url;
  final DateTime? visitTime;
  final int? visitDuration;
  final String? title;
  final int? visitCount;
  final DateTime? lastVisitTime;

  History({
    this.url,
    this.visitTime,
    this.visitDuration,
    this.title,
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
        "visit_time": visitTime,
        "visit_duration": visitDuration,
        "title": title,
        "visit_count": visitCount,
        "last_visit_time": lastVisitTime,
      };
}
