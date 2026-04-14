// lib/core/models/ai_insight.dart

/// Represents a cached AI analysis of a word.
/// Stored as JSON in Hive so no code generation needed.
class AiInsight {
  final String word;
  final String definition;
  final String fact;
  final String modelDisplayName;
  final String modelId;
  final DateTime cachedAt;

  const AiInsight({
    required this.word,
    required this.definition,
    required this.fact,
    required this.modelDisplayName,
    required this.modelId,
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    'definition': definition,
    'fact': fact,
    'modelDisplayName': modelDisplayName,
    'modelId': modelId,
    'cachedAt': cachedAt.millisecondsSinceEpoch,
  };

  factory AiInsight.fromJson(Map<String, dynamic> json) => AiInsight(
    word: json['word'] as String,
    definition: json['definition'] as String,
    fact: json['fact'] as String,
    modelDisplayName: json['modelDisplayName'] as String,
    modelId: json['modelId'] as String,
    cachedAt: DateTime.fromMillisecondsSinceEpoch(json['cachedAt'] as int),
  );
}
