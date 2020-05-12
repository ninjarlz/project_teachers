import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/participant_entity.dart';

class ConversationEntity {
  String id; //lowerParticipantId_higherParticipantId
  List<String> participants;
  Map<String, ParticipantEntity> participantsData;
  Timestamp lastMsgTimestamp;
  String lastMsgSenderId;
  String lastMsgText;
  bool lastMsgSeen;
  String otherParticipantId;
  ParticipantEntity otherParticipantData;
  ParticipantEntity currentUserData;

  ConversationEntity(
      this.participants,
      this.participantsData,
      this.lastMsgTimestamp,
      this.lastMsgSenderId,
      this.lastMsgText,
      this.lastMsgSeen);

  factory ConversationEntity.fromJson(Map<String, dynamic> json) {
    return ConversationEntity(
        List<String>.from(json["participants"]),
        mapParticipantsData(json["participantsData"]),
        json["lastMsgTimestamp"],
        json["lastMsgSenderId"],
        json["lastMsgText"],
        json["lastMsgSeen"]);
  }

  factory ConversationEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return ConversationEntity(
        List<String>.from(documentSnapshot.data["participants"]),
        mapParticipantsData(documentSnapshot.data["participantsData"]),
        documentSnapshot.data["lastMsgTimestamp"],
        documentSnapshot.data["lastMsgSenderId"],
        documentSnapshot.data["lastMsgText"],
        documentSnapshot.data["lastMsgSeen"]);
  }

  toJson() {
    return {
      "participants": participants,
      "participantsData": participantsDataToMap(participantsData),
      "lastMsgTimestamp": lastMsgTimestamp,
      "lastMsgSenderId": lastMsgSenderId,
      "lastMsgText": lastMsgText,
      "lastMsgSeen": lastMsgSeen
    };
  }

  static Map<String, ParticipantEntity> mapParticipantsData(
      Map<String, dynamic> data) {
    return data.map((key, value) =>
        MapEntry<String, ParticipantEntity>(
            key, ParticipantEntity.fromJson(value)));
  }

  static Map<String, dynamic> participantsDataToMap(
      Map<String, ParticipantEntity> participantsData) {
    return participantsData
        .map((key, value) => MapEntry<String, dynamic>(key, value.toJson()));
  }

  static String getConversationId(String user1Id, String user2Id) {
    List<String> ids = [user1Id, user2Id];
    ids.sort((a, b) {
      return a.compareTo(b);
    });
    return ids[0] + "_" + ids[1];
  }
}
