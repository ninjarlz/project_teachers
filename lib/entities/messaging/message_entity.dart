import 'package:cloud_firestore/cloud_firestore.dart';

class MessageEntity {

  String id;
  String text;
  String senderId;
  Timestamp timestamp;

  MessageEntity(this.text, this.senderId,
      this.timestamp);

  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    return MessageEntity(
        json["text"],
        json["senderId"],
        json["timestamp"]);
  }

  factory MessageEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return MessageEntity(
        documentSnapshot.data["text"],
        documentSnapshot.data["senderId"],
        documentSnapshot.data["timestamp"]);
  }

  toJson() {
    return {
      "text": text,
      "senderId": senderId,
      "timestamp": timestamp
    };
  }
}