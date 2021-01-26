import 'package:cloud_firestore/cloud_firestore.dart';

class MessageEntity {
  static const String ID_FIELD_NAME = "id";
  static const String TEXT_FIELD_NAME = "text";
  static const String SENDER_ID_FIELD_NAME = "senderId";
  static const String TIMESTAMP_FIELD_NAME = "timestamp";

  String id;
  String text;
  String senderId;
  Timestamp timestamp;

  MessageEntity(this.text, this.senderId, this.timestamp);

  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    return MessageEntity(json[TEXT_FIELD_NAME], json[SENDER_ID_FIELD_NAME], json[TIMESTAMP_FIELD_NAME]);
  }

  factory MessageEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return MessageEntity(documentSnapshot.data[TEXT_FIELD_NAME], documentSnapshot.data[SENDER_ID_FIELD_NAME],
        documentSnapshot.data[TIMESTAMP_FIELD_NAME]);
  }

  toJson() {
    return {TEXT_FIELD_NAME: text, SENDER_ID_FIELD_NAME: senderId, TIMESTAMP_FIELD_NAME: timestamp};
  }
}
