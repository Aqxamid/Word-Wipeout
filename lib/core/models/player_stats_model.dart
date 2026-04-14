// lib/core/models/player_stats_model.dart
import 'package:hive/hive.dart';

part 'player_stats_model.g.dart';

@HiveType(typeId: 1)
class PlayerStatsModel extends HiveObject {
  @HiveField(0)
  int gamesPlayed;

  @HiveField(1)
  int gamesWon;

  @HiveField(2)
  int currentStreak;

  @HiveField(3)
  int bestStreak;

  @HiveField(4)
  Map<int, int> guessDistribution; // attempt# -> count

  @HiveField(5)
  int rageModeLives;

  @HiveField(6)
  int totalRageRuns;

  PlayerStatsModel({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    Map<int, int>? guessDistribution,
    this.rageModeLives = 3,
    this.totalRageRuns = 0,
  }) : guessDistribution = guessDistribution ?? {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0};

  double get winRate => gamesPlayed == 0 ? 0 : (gamesWon / gamesPlayed) * 100;

  void recordWin(int attempts) {
    gamesPlayed++;
    gamesWon++;
    currentStreak++;
    if (currentStreak > bestStreak) bestStreak = currentStreak;
    final key = attempts.clamp(1, 8);
    guessDistribution[key] = (guessDistribution[key] ?? 0) + 1;
  }

  void recordLoss() {
    gamesPlayed++;
    // currentStreak represents 'Level'. We do not reset level upon losing.
  }
}
