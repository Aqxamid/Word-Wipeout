// lib/core/services/storage_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/word_model.dart';
import '../models/player_stats_model.dart';
import '../models/game_history_model.dart';
import '../models/active_game_model.dart';

class StorageService {
  static const String _wordsBox = 'words';
  static const String _customWordsBox = 'custom_words';
  static const String _statsBox = 'player_stats';
  static const String _historyBox = 'game_history';
  static const String _usedWordsBox = 'used_words';
  static const String _settingsBox = 'settings';
  static const String _activeGameBox = 'active_game';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WordModelAdapter());
    Hive.registerAdapter(PlayerStatsModelAdapter());
    Hive.registerAdapter(GameHistoryModelAdapter());
    Hive.registerAdapter(ActiveGameModelAdapter());

    await Hive.openBox<WordModel>(_wordsBox);
    await Hive.openBox<WordModel>(_customWordsBox);
    await Hive.openBox<PlayerStatsModel>(_statsBox);
    await Hive.openBox<GameHistoryModel>(_historyBox);
    await Hive.openBox<String>(_usedWordsBox);
    await Hive.openBox<String>(_settingsBox);
    await Hive.openBox<ActiveGameModel>(_activeGameBox);
  }

  // ── Active Game Methods ───────────────────────────────────────
  Box<ActiveGameModel> get _activeGameStore => Hive.box<ActiveGameModel>(_activeGameBox);

  Future<void> saveActiveGame(ActiveGameModel game) async {
    await _activeGameStore.put('current', game);
  }

  ActiveGameModel? getActiveGame() {
    return _activeGameStore.get('current');
  }

  Future<void> clearActiveGame() async {
    await _activeGameStore.delete('current');
  }

  // ── Word Methods ──────────────────────────────────────────────
  Box<WordModel> get _words => Hive.box<WordModel>(_wordsBox);
  Box<WordModel> get _customWords => Hive.box<WordModel>(_customWordsBox);

  Future<void> seedDefaultWords(List<WordModel> words) async {
    if (_words.isEmpty) {
      for (final w in words) {
        await _words.add(w);
      }
    }
  }

  List<WordModel> getDefaultWords() => _words.values.toList();

  List<WordModel> getCustomWords() => _customWords.values.toList();

  Future<void> addCustomWord(WordModel word) async {
    await _customWords.add(word);
  }

  Future<void> deleteCustomWord(int index) async {
    await _customWords.deleteAt(index);
  }

  Future<void> clearCustomWords() async {
    await _customWords.clear();
  }

  // ── Stats Methods ─────────────────────────────────────────────
  Box<PlayerStatsModel> get _statsStore => Hive.box<PlayerStatsModel>(_statsBox);

  PlayerStatsModel getStats() {
    if (_statsStore.isEmpty) {
      final stats = PlayerStatsModel();
      _statsStore.add(stats);
      return stats;
    }
    return _statsStore.getAt(0)!;
  }

  Future<void> saveStats(PlayerStatsModel stats) async {
    if (_statsStore.isEmpty) {
      await _statsStore.add(stats);
    } else {
      await stats.save();
    }
  }

  // ── History Methods ───────────────────────────────────────────
  Box<GameHistoryModel> get _history => Hive.box<GameHistoryModel>(_historyBox);

  Future<void> addHistory(GameHistoryModel entry) async {
    await _history.add(entry);
    // Keep only last 100
    while (_history.length > 100) {
      await _history.deleteAt(0);
    }
  }

  List<GameHistoryModel> getHistory() =>
      _history.values.toList().reversed.toList();

  // ── Used Words Methods ────────────────────────────────────────
  Box<String> get _usedWords => Hive.box<String>(_usedWordsBox);

  Future<void> markWordUsed(String word) async {
    if (!_usedWords.values.contains(word)) {
      await _usedWords.add(word);
    }
  }

  List<String> getUsedWords() => _usedWords.values.toList();

  Future<void> clearUsedWords() async {
    await _usedWords.clear();
  }

  // ── Settings Methods ──────────────────────────────────────────
  Box<String> get _settings => Hive.box<String>(_settingsBox);

  String getSetting(String key, {String fallback = ''}) =>
      _settings.get(key) ?? fallback;

  Future<void> putSetting(String key, String value) async =>
      _settings.put(key, value);

  Future<void> removeSetting(String key) async =>
      _settings.delete(key);
}
