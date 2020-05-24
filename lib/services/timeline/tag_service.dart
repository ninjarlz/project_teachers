import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/timeline/tag_entity.dart';
import 'package:project_teachers/repositories/timeline/tag_repository.dart';

class TagService {
  TagService._privateConstructor();

  static TagService _instance;

  static TagService get instance {
    if (_instance == null) {
      _instance = TagService._privateConstructor();
      _instance._tagRepository = TagRepository.instance;
    }
    return _instance;
  }

  TagRepository _tagRepository;

  Future<List<TagEntity>> getTagsSuggestions(String input) async {
    return await _tagRepository.getTagsSuggestions(input);
  }

  Future<List<String>> getTagsSuggestionsStrings(String input) async {
    List<TagEntity> tagsSuggestions = await getTagsSuggestions(input);
    return tagsSuggestions
        .map((e) => e.value + "  " + e.postsCounter.toString() + " post(s)")
        .toList();
  }

  Future<void> transactionPostTags(
      List<String> tags, Transaction transaction) async {
    await _tagRepository.transactionPostTags(tags, transaction);
  }
}
