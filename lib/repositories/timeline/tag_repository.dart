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

  Future<void> increaseTagCounter(String tag) async {
    _database.runTransaction((transaction) async {
      await transaction.update(
          _tagsRef.document(tag), {"postsCounter": FieldValue.increment(1)});
    });
  }

  Future<bool> checkIfTagExists(String tag) async {
    DocumentSnapshot documentSnapshot = await _tagsRef.document(tag).get();
    return documentSnapshot.exists;
  }

  Future<void> createTag(String tag) async {
    await _tagsRef.document(tag).setData(TagEntity(tag, 1).toJson());
  }
}
