import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  ObjectId id;
  String title;
  String description;
  String date;
  String status;

  Welcome({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) {
    return Welcome(
      id: json["_id"] ?? ObjectId(),
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      date: json["date"] ?? "",
      status: json["status"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "date": date,
        "status": status,
      };
}
