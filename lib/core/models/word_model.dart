// lib/core/models/word_model.dart
import 'package:hive/hive.dart';

part 'word_model.g.dart';

@HiveType(typeId: 0)
class WordModel extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final int length;

  @HiveField(2)
  final int difficulty; // 1=easy, 2=medium, 3=hard

  @HiveField(3)
  final List<String> tags;

  @HiveField(4)
  final bool isCustom;

  WordModel({
    required this.text,
    required this.length,
    required this.difficulty,
    required this.tags,
    this.isCustom = false,
  });

  factory WordModel.fromString(String word, {bool isCustom = false}) {
    int diff = 1;
    if (word.length >= 7) diff = 3;
    else if (word.length >= 5) diff = 2;
    return WordModel(
      text: word.toUpperCase(),
      length: word.length,
      difficulty: diff,
      tags: [],
      isCustom: isCustom,
    );
  }
}
