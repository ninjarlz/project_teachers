import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationEntity {

  String id;
  List<String> participants;
  Timestamp lastMsgTimestamp;
  String lastMsgSenderId;
  String lastMsgText;

  ConversationEntity(this.participants, this.lastMsgTimestamp,
      this.lastMsgSenderId, this.lastMsgText);

  factory ConversationEntity.fromJson(Map<String, dynamic> json) {
    return ConversationEntity(
        json["participants"],
        json["lastMsgTimestamp"],
        json["lastMsgSenderId"],
        json["lastMsgText"]);
  }

  factory ConversationEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return ConversationEntity(
        documentSnapshot.data["participants"],
        documentSnapshot.data["lastMsgTimestamp"],
        documentSnapshot.data["lastMsgSenderId"],
        documentSnapshot.data["lastMsgText"]);
  }

  toJson() {
    return {
      "participants": participants,
      "lastMsgTimestamp": lastMsgTimestamp,
      "lastMsgSenderId": lastMsgSenderId,
      "lastMsgText": lastMsgText
    };
  }

}