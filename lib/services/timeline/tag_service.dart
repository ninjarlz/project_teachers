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

  Future<void> postTag(String tag) async {
    bool tagExists = await _tagRepository.checkIfTagExists(tag);
    if (tagExists) {
      _tagRepository.increaseTagCounter(tag);
    } else {
      _tagRepository.createTag(tag);
    }
  }
}
