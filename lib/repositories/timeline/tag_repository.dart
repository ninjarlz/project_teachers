import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/timeline/tag_entity.dart';

class TagRepository {
  static const String DB_ERROR_MSG = "An error with database occured: ";
  static const String TAGS_COLLECTION = "Tags";
  static const String LAST_UNICODE = "\uf8ff";
  static const int TAGS_SUGGESTIONS_LIMIT = 5;

  TagRepository._privateConstructor();

  static TagRepository _instance;

  static TagRepository get instance {
    if (_instance == null) {
      _instance = TagRepository._privateConstructor();
      _instance._database = Firestore.instance;
      _instance._tagsRef = _instance._database.collection(TAGS_COLLECTION);
    }
    return _instance;
  }

  Firestore _database;
  CollectionReference _tagsRef;

  Future<List<TagEntity>> getTagsSuggestions(String input) async {
    QuerySnapshot querySnapshot = await _tagsRef
        .orderBy(TagEntity.VALUE_FIELD_NAME)
        .startAt([input])
        .endAt([input + LAST_UNICODE])
        .limit(TAGS_SUGGESTIONS_LIMIT)
        .getDocuments();
    return querySnapshot.documents.map((documentSnapshot) => TagEntity.fromSnapshot(documentSnapshot));
  }

  Future<bool> transactionCheckIfTagExists(String tag, Transaction transaction) async {
    DocumentSnapshot documentSnapshot = await transaction.get(_tagsRef.document(tag));
    return documentSnapshot.exists;
  }

  Future<void> transactionPostTags(List<String> tags, Transaction transaction) async {
    Map<String, bool> tagsExistenceMap = await _transactionCheckTagsExistence(tags, transaction);
    await _transactionPostTagsWithExistenceMap(tags, tagsExistenceMap, transaction);
  }

  Future<void> transactionRemoveAndPostTags(
      List<String> tagsToRemove, List<String> tagsToPost, Transaction transaction) async {
    Map<String, bool> postTagsExistenceMap = await _transactionCheckTagsExistence(tagsToPost, transaction);
    await _transactionRemoveTags(tagsToRemove, transaction);
    await _transactionPostTagsWithExistenceMap(tagsToPost, postTagsExistenceMap, transaction);
  }

  Future<void> _transactionPostTagsWithExistenceMap(
      List<String> tagsToPost, Map<String, bool> postTagsExistenceMap, Transaction transaction) async {
    for (String tag in tagsToPost) {
      if (postTagsExistenceMap[tag]) {
        await _transactionChangePostCounterTag(_tagsRef.document(tag), 1, transaction);
      } else {
        await transaction.set(_tagsRef.document(tag), TagEntity(tag, 1).toJson());
      }
    }
  }

  Future<void> _transactionRemoveTags(List<String> tagsToRemove, Transaction transaction) async {
    List<DocumentSnapshot> removeTagsSnapshot = List<DocumentSnapshot>();
    for (String tag in tagsToRemove) {
      removeTagsSnapshot.add(await transaction.get(_tagsRef.document(tag)));
    }
    for (DocumentSnapshot documentSnapshot in removeTagsSnapshot) {
      await _transactionRemoveTagSnapshot(documentSnapshot, transaction);
    }
  }

  Future<void> _transactionChangePostCounterTag(
      DocumentReference documentReference, int delta, Transaction transaction) async {
    await transaction.update(documentReference, {TagEntity.POSTS_COUNTER_FIELD_NAME: FieldValue.increment(delta)});
  }

  bool _isTagNotAssignedAnywhere(DocumentSnapshot documentSnapshot) {
    return documentSnapshot.data[TagEntity.POSTS_COUNTER_FIELD_NAME] == null ||
        documentSnapshot.data[TagEntity.POSTS_COUNTER_FIELD_NAME] <= 1;
  }

  Future<Map<String, bool>> _transactionCheckTagsExistence(List<String> tagsToCheck, Transaction transaction) async {
    Map<String, bool> tagsExistenceMap = Map<String, bool>();
    for (String tag in tagsToCheck) {
      tagsExistenceMap[tag] = await transactionCheckIfTagExists(tag, transaction);
    }
    return tagsExistenceMap;
  }

  Future<void> _transactionRemoveTagSnapshot(DocumentSnapshot documentSnapshot, Transaction transaction) async {
    if (documentSnapshot.exists) {
      if (_isTagNotAssignedAnywhere(documentSnapshot)) {
        await transaction.delete(_tagsRef.document(documentSnapshot.documentID));
      } else {
        await _transactionChangePostCounterTag(_tagsRef.document(documentSnapshot.documentID), -1, transaction);
      }
    } else {
      await transaction.set(_tagsRef.document(documentSnapshot.documentID), {});
    }
  }
}
