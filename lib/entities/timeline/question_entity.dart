import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/participant_entity.dart';

class QuestionEntity {
  String id;
  String authorId;
  ParticipantEntity authorData;
  Timestamp timestamp;
  String content;
  int reactionsCounter;
  int answersCounter;
  List<String> photoNames;
  List<String> tags;

  QuestionEntity(this.authorId, this.authorData, this.timestamp, this.content,
      this.reactionsCounter, this.answersCounter, this.photoNames, this.tags);

  factory QuestionEntity.fromJson(Map<String, dynamic> json) {
    return QuestionEntity(
        json["authorId"],
        ParticipantEntity.fromJson(json["authorData"]),
        json["timestamp"],
        json["content"],
        json["reactionsCounter"],
        json["answersCounter"],
        json["photoNames"] != null
            ? List<String>.from(json["photoNames"])
            : null,
        List<String>.from(json["tags"]));
  }

  factory QuestionEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return QuestionEntity(
        documentSnapshot.data["authorId"],
        ParticipantEntity.fromJson(documentSnapshot.data["authorData"]),
        documentSnapshot.data["timestamp"],
        documentSnapshot.data["content"],
        documentSnapshot.data["reactionsCounter"],
        documentSnapshot.data["answersCounter"],
        documentSnapshot.data["photoNames"] != null
            ? List<String>.from(documentSnapshot.data["photoNames"])
            : null,
        List<String>.from(documentSnapshot.data["tags"]));
  }

  toJson() {
    return {
      "authorId": authorId,
      "authorData": authorData.toJson(),
      "timestamp": timestamp,
      "content": content,
      "reactionsCounter": reactionsCounter,
      "answersCounter": answersCounter,
      "photoNames": photoNames,
      "tags": tags
    };
  }
}
