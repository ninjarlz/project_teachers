import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/timeline/tag_entity.dart';

class TagRepository {
  static const String DB_ERROR_MSG = "An error with database occured: ";

  TagRepository._privateConstructor();

  static TagRepository _instance;

  static TagRepository get instance {
    if (_instance == null) {
      _instance = TagRepository._privateConstructor();
      _instance._database = Firestore.instance;
      _instance._tagsRef = _instance._database.collection("Tags");
    }
    return _instance;
  }

  Firestore _database;
  CollectionReference _tagsRef;

  Future<List<TagEntity>> getTagsSuggestions(String input) async {
    List<TagEntity> suggestions = List<TagEntity>();
    QuerySnapshot querySnapshot = await _tagsRef
        .orderBy("value")
        .startAt([input])
        .endAt([input + "\uf8ff"])
        .limit(5)
        .getDocuments();
    for (DocumentSnapshot documentSnapshot in querySnapshot.documents) {
      suggestions.add(TagEntity.fromSnapshot(documentSnapshot));
    }
    return suggestions;
  }

  Future<bool> transactionCheckIfTagExists(
      String tag, Transaction transaction) async {
    DocumentSnapshot documentSnapshot =
        await transaction.get(_tagsRef.document(tag));
    return documentSnapshot.exists;
  }

  Future<void> transactionPostTags(
      List<String> tags, Transaction transaction) async {
    List<bool> tagsExists = List<bool>();
    for (String tag in tags) {
      tagsExists.add(await transactionCheckIfTagExists(tag, transaction));
    }
    for (int i = 0; i < tags.length; i++) {
      if (tagsExists[i]) {
        await transaction.update(_tagsRef.document(tags[i]),
            {"postsCounter": FieldValue.increment(1)});
      } else {
        await transaction.set(
            _tagsRef.document(tags[i]), TagEntity(tags[i], 1).toJson());
      }
    }
  }

  Future<void> transactionPostAndRemoveTags(List<String> tagsToRemove,
      List<String> tagsToPost, Transaction transaction) async {
    List<bool> addTagsExists = List<bool>();
    for (String tag in tagsToPost) {
      addTagsExists.add(await transactionCheckIfTagExists(tag, transaction));
    }

    List<DocumentSnapshot> removeTagsSnapshot = List<DocumentSnapshot>();
    for (String tag in tagsToRemove) {
      removeTagsSnapshot.add(await transaction.get(_tagsRef.document(tag)));
    }

    for (DocumentSnapshot documentSnapshot in removeTagsSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.data["postsCounter"] <= 1 ||
            documentSnapshot.data["postsCounter"] == null) {
          await transaction
              .delete(_tagsRef.document(documentSnapshot.documentID));
        } else {
          await transaction.update(
              _tagsRef.document(documentSnapshot.documentID),
              {"postsCounter": FieldValue.increment(-1)});
        }
      } else {
        await transaction
            .set(_tagsRef.document(documentSnapshot.documentID), {});
      }
    }

    for (int i = 0; i < tagsToPost.length; i++) {
      if (addTagsExists[i]) {
        await transaction.update(_tagsRef.document(tagsToPost[i]),
            {"postsCounter": FieldValue.increment(1)});
      } else {
        await transaction.set(_tagsRef.document(tagsToPost[i]),
            TagEntity(tagsToPost[i], 1).toJson());
      }
    }
  }
}
