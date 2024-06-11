import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:task/MongoDbModel.dart';
import 'package:task/db/constant.dart';

class MongoDatabase {
  static late Db db;
  static late DbCollection userCollection;

  static Future<void> connect() async {
    db = await Db.create(MONGO_CONN_URL);
    await db.open();
    inspect(db);
    userCollection = db.collection(USER_COLLECTION);
  }

  static Future<List<Map<String, dynamic>>> getData() async {
    final arrData = await userCollection.find().toList();
    return arrData;
  }

  static Future<void> delete(ObjectId id) async {
    await userCollection.remove(where.id(id));
  }

  static Future<Map<String, dynamic>?> update(Welcome data) async {
    try {
      var result = await userCollection.updateOne(
        where.id(data.id),
        modify
            .set('title', data.title)
            .set('description', data.description)
            .set('date', data.date)
            .set('status', data.status),
      );

      if (result.isAcknowledged) {
        print("Document updated successfully");
        return await userCollection.findOne(where.id(data.id));
      } else {
        print("Document not found or not updated");
        return null;
      }
    } catch (e) {
      print("Error updating document: $e");
      return null;
    }
  }

  static Future<String> insert(Welcome data) async {
    try {
      var result = await userCollection.insertOne(data.toJson());
      if (result.isSuccess) {
        return "Data Inserted";
      } else {
        return "Something went wrong while inserting data.";
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }
}
