// lib/core/models/active_game_model.dart
import 'package:hive/hive.dart';

part 'active_game_model.g.dart';

@HiveType(typeId: 4)
class ActiveGameModel extends HiveObject {
  @HiveField(0)
  final String targetWord;

  @HiveField(1)
  final List<String> guesses;

  @HiveField(2)
  final String currentInput;

  @HiveField(3)
  final String gameMode;

  @HiveField(4)
  final int maxAttempts;

  @HiveField(5)
  final int rageLives;

  ActiveGameModel({
    required this.targetWord,
    required this.guesses,
    required this.currentInput,
    required this.gameMode,
    required this.maxAttempts,
    required this.rageLives,
  });
}
