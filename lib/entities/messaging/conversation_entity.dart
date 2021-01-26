import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/participant_entity.dart';

class ConversationEntity {
  static const String ID_FIELD_NAME = "id";
  static const String PARTICIPANTS_FIELD_NAME = "participants";
  static const String PARTICIPANTS_DATA_FIELD_NAME = "participantsData";
  static const String LAST_MSG_TIMESTAMP_FIELD_NAME = "lastMsgTimestamp";
  static const String LAST_MSG_SENDER_ID_FIELD_NAME = "lastMsgSenderId";
  static const String LAST_MSG_TEXT_FIELD_NAME = "lastMsgText";
  static const String LAST_MSG_SEEN_FIELD_NAME = "lastMsgSeen";

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

  ConversationEntity(this.participants, this.participantsData, this.lastMsgTimestamp, this.lastMsgSenderId,
      this.lastMsgText, this.lastMsgSeen);

  factory ConversationEntity.fromJson(Map<String, dynamic> json) {
    return ConversationEntity(
        List<String>.from(json[PARTICIPANTS_FIELD_NAME]),
        mapParticipantsData(json[PARTICIPANTS_DATA_FIELD_NAME]),
        json[LAST_MSG_TIMESTAMP_FIELD_NAME],
        json[LAST_MSG_SENDER_ID_FIELD_NAME],
        json[LAST_MSG_TEXT_FIELD_NAME],
        json[LAST_MSG_SEEN_FIELD_NAME]);
  }

  factory ConversationEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return ConversationEntity(
        List<String>.from(documentSnapshot.data[PARTICIPANTS_FIELD_NAME]),
        mapParticipantsData(documentSnapshot.data[PARTICIPANTS_DATA_FIELD_NAME]),
        documentSnapshot.data[LAST_MSG_TIMESTAMP_FIELD_NAME],
        documentSnapshot.data[LAST_MSG_SENDER_ID_FIELD_NAME],
        documentSnapshot.data[LAST_MSG_TEXT_FIELD_NAME],
        documentSnapshot.data[LAST_MSG_SEEN_FIELD_NAME]);
  }

  toJson() {
    return {
      PARTICIPANTS_FIELD_NAME: participants,
      PARTICIPANTS_DATA_FIELD_NAME: participantsDataToMap(participantsData),
      LAST_MSG_TIMESTAMP_FIELD_NAME: lastMsgTimestamp,
      LAST_MSG_SENDER_ID_FIELD_NAME: lastMsgSenderId,
      LAST_MSG_TEXT_FIELD_NAME: lastMsgText,
      LAST_MSG_SEEN_FIELD_NAME: lastMsgSeen
    };
  }

  static Map<String, ParticipantEntity> mapParticipantsData(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry<String, ParticipantEntity>(key, ParticipantEntity.fromJson(value)));
  }

  static Map<String, dynamic> participantsDataToMap(Map<String, ParticipantEntity> participantsData) {
    return participantsData.map((key, value) => MapEntry<String, dynamic>(key, value.toJson()));
  }

  static String getConversationId(String user1Id, String user2Id) {
    List<String> ids = [user1Id, user2Id];
    ids.sort((a, b) {
      return a.compareTo(b);
    });
    return ids[0] + "_" + ids[1];
  }
}
