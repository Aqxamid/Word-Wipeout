// lib/core/models/game_history_model.dart
import 'package:hive/hive.dart';

part 'game_history_model.g.dart';

@HiveType(typeId: 2)
class GameHistoryModel extends HiveObject {
  @HiveField(0)
  final String word;

  @HiveField(1)
  final String mode; // classic, custom, rage

  @HiveField(2)
  final bool won;

  @HiveField(3)
  final int attemptsUsed;

  @HiveField(4)
  final DateTime playedAt;

  GameHistoryModel({
    required this.word,
    required this.mode,
    required this.won,
    required this.attemptsUsed,
    required this.playedAt,
  });
}
