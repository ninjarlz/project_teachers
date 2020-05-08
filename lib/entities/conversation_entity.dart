import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/conversation_participant_entity.dart';

class ConversationEntity {
  String id;
  List<String> participants;
  Map<String, ConversationParticipantEntity> participantsData;
  Timestamp lastMsgTimestamp;
  String lastMsgSenderId;
  String lastMsgText;
  String otherParticipantId;
  ConversationParticipantEntity otherParticipantData;
  ConversationParticipantEntity currentUserData;

  ConversationEntity(this.participants, this.participantsData,
      this.lastMsgTimestamp, this.lastMsgSenderId, this.lastMsgText);

  factory ConversationEntity.fromJson(Map<String, dynamic> json) {
    return ConversationEntity(
        List<String>.from(json["participants"]),
        mapParticipantsData(json["participantsData"]),
        json["lastMsgTimestamp"],
        json["lastMsgSenderId"],
        json["lastMsgText"]);
  }

  factory ConversationEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return ConversationEntity(
        List<String>.from(documentSnapshot.data["participants"]),
        mapParticipantsData(documentSnapshot.data["participantsData"]),
        documentSnapshot.data["lastMsgTimestamp"],
        documentSnapshot.data["lastMsgSenderId"],
        documentSnapshot.data["lastMsgText"]);
  }

  toJson() {
    return {
      "participants": participants,
      "participantsData": participantsData,
      "lastMsgTimestamp": lastMsgTimestamp,
      "lastMsgSenderId": lastMsgSenderId,
      "lastMsgText": lastMsgText
    };
  }

  static Map<String, ConversationParticipantEntity> mapParticipantsData(
      Map<String, dynamic> data) {
    return data.map((key, value) =>
        MapEntry<String, ConversationParticipantEntity>(
            key, ConversationParticipantEntity.fromJson(value)));
  }
}
