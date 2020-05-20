import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/participant_entity.dart';

class AnswerEntity {
  String id;
  String authorId;
  ParticipantEntity authorData;
  Timestamp timestamp;
  String content;
  int reactionsCounter;
  List<String> photoNames;

  AnswerEntity(this.authorId, this.authorData, this.timestamp, this.content,
      this.reactionsCounter, this.photoNames);

  factory AnswerEntity.fromJson(Map<String, dynamic> json) {
    return AnswerEntity(
        json["authorId"],
        ParticipantEntity.fromJson(json["authorData"]),
        json["timestamp"],
        json["content"],
        json["reactionsCounter"],
        json["photoNames"]);
  }

  factory AnswerEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return AnswerEntity(
        documentSnapshot.data["authorId"],
        ParticipantEntity.fromJson(documentSnapshot.data["authorData"]),
        documentSnapshot.data["timestamp"],
        documentSnapshot.data["content"],
        documentSnapshot.data["reactionsCounter"],
        documentSnapshot.data["photoNames"]);
  }

  toJson() {
    return {
      "authorId": authorId,
      "authorData": authorData.toJson(),
      "timestamp": timestamp,
      "content": content,
      "reactionsCounter": reactionsCounter,
      "photoNames": photoNames
    };
  }
}
