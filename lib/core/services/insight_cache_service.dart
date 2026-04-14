// lib/core/services/insight_cache_service.dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ai_insight.dart';

/// Permanently caches AI word insights in a Hive box.
/// Key = uppercase word. Value = JSON string.
/// Once stored, insights survive app restarts and model changes.
class InsightCacheService {
  static const String _boxName = 'ai_insights';

  static Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  Box<String> get _box => Hive.box<String>(_boxName);

  /// Returns cached insight for [word], or null if not cached.
  AiInsight? get(String word) {
    final raw = _box.get(word.toUpperCase());
    if (raw == null) return null;
    try {
      return AiInsight.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Stores [insight] permanently. Overwrites any previous entry for the word.
  Future<void> store(AiInsight insight) async {
    await _box.put(
      insight.word.toUpperCase(),
      jsonEncode(insight.toJson()),
    );
  }

  /// Whether [word] already has a cached insight.
  bool has(String word) => _box.containsKey(word.toUpperCase());

  /// Total number of cached words.
  int get count => _box.length;

  /// Clear all cached insights (settings reset).
  Future<void> clearAll() async => _box.clear();
}
