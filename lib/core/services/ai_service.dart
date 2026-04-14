import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:llama_flutter_android/llama_flutter_android.dart';
import '../models/ai_model.dart';
import '../models/ai_insight.dart';

class AiService {
  final AiModel model;
  final String apiKey;
  final String ggufPath;

  LlamaController? _llama;
  bool _isLlamaLoaded = false;

  AiService({
    required this.model,
    required this.apiKey,
    required this.ggufPath,
  });

  Future<void> dispose() async {
    if (_isLlamaLoaded && _llama != null) {
      await _llama!.dispose();
      _isLlamaLoaded = false;
      _llama = null;
    }
  }

  // ── Validation ────────────────────────────────────────────────
  //
  // Anti-hallucination prompt: forces a single YES/NO token.
  // Tiny models (1B–3B) respond reliably to this exact format.

  String _validationPrompt(String word) =>
      'Answer with exactly one word: YES or NO\n'
      'Is "$word" a real English dictionary word?';

  // ── Insight ──────────────────────────────────────────────────
  //
  // Strict labeled template — works even on TinyLlama 1.1B.
  // We parse DEFINITION/FACT labels so model creativity is contained.

  String _insightPrompt(String word) =>
      'Complete only these two lines about the English word $word. '
      'No explanation. No extra text. Stay under 12 words per line.\n'
      'DEFINITION: [one sentence definition]\n'
      'FACT: [one interesting fact]';

  // ── Public API ────────────────────────────────────────────────

  /// Returns true if [word] is recognised as a real English word.
  /// Falls back to true on any error so gameplay is never blocked.
  Future<bool> validateWord(String word) async {
    try {
      final prompt = _validationPrompt(word);
      final raw = await _send(
        prompt: prompt,
        maxTokens: 5,
        temperature: 0.0,   // zero creativity for classification
        numPredict: 5,
      );
      final answer = raw.trim().toUpperCase();
      // Accept if response starts with Y or contains YES
      return answer.startsWith('Y') || answer.contains('YES');
    } catch (_) {
      return true; // fail-open: don't block gameplay
    }
  }

  /// Returns an [AiInsight] for [word], or null on failure.
  Future<AiInsight?> analyzeWord(String word) async {
    final prompt = _insightPrompt(word);
    final raw = await _send(
      prompt: prompt,
      maxTokens: 80,
      temperature: 0.2,
      numPredict: 80,
    );
    return _parseInsight(word, raw);
  }

  // ── Routing ───────────────────────────────────────────────────

  Future<String> _send({
    required String prompt,
    required int maxTokens,
    required double temperature,
    required int numPredict,
  }) async {
    switch (model.provider) {
      case AiProvider.google:
        return _callGemini(prompt, maxTokens, temperature);
      case AiProvider.local:
        return _callLocalGguf(prompt, numPredict, temperature);
    }
  }

  // ── Google Gemini ─────────────────────────────────────────────

  Future<String> _callGemini(
      String prompt, int maxTokens, double temperature) async {
    final url = Uri.parse(
        '${model.endpoint}/${model.modelId}:generateContent?key=$apiKey');
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'maxOutputTokens': maxTokens,
        'temperature': temperature,
        'topP': 0.3,
      },
    });

    final resp = await http
        .post(url,
            headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 15));

    _assertOk(resp);
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    return json['candidates'][0]['content']['parts'][0]['text'] as String;
  }


  // ── Local LLM (Llama FFI) ───────────────────────────────────
  //
  // Loads GGUF directly onto RAM via llama_flutter_android bindings
  
  Future<String> _callLocalGguf(
      String prompt, int numPredict, double temperature) async {
    
    if (ggufPath.isEmpty) {
      throw Exception('No GGUF file path selected. Please load one in Settings.');
    }

    if (!_isLlamaLoaded || _llama == null) {
      _llama = LlamaController();
      try {
        await _llama!.loadModel(modelPath: ggufPath);
        _isLlamaLoaded = true;
      } catch (e) {
        throw Exception('Native Llama FFI failed to load model. $e');
      }
    }

    final stream = _llama!.generate(prompt: prompt, maxTokens: numPredict);
    String response = '';
    await for (final token in stream) {
      response += token;
    }

    if (response.isEmpty) {
      throw Exception('Llama FFI returned empty output');
    }
    
    return response;
  }

  // ── Parsing ───────────────────────────────────────────────────

  AiInsight _parseInsight(String word, String raw) {
    final text = raw.trim();

    // Try labeled format first (DEFINITION: ... / FACT: ...)
    final defMatch =
        RegExp(r'DEFINITION:\s*\[?(.+?)(?:\]|\n|$)', caseSensitive: false)
            .firstMatch(text);
    final factMatch =
        RegExp(r'FACT:\s*\[?(.+?)(?:\]|\n|$)', caseSensitive: false)
            .firstMatch(text);

    String definition;
    String fact;

    if (defMatch != null && factMatch != null) {
      definition = defMatch.group(1)!.trim();
      fact = factMatch.group(1)!.trim();
    } else {
      // Fallback: split by newline and take first two non-empty lines
      final lines = text
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      definition = lines.isNotEmpty ? _cleanLine(lines[0]) : 'A word.';
      fact = lines.length > 1 ? _cleanLine(lines[1]) : 'Used in English.';
    }

    // Truncate to avoid display overflow
    if (definition.length > 120) definition = '${definition.substring(0, 117)}…';
    if (fact.length > 120) fact = '${fact.substring(0, 117)}…';

    return AiInsight(
      word: word,
      definition: definition,
      fact: fact,
      modelDisplayName: model.displayName,
      modelId: model.id,
      cachedAt: DateTime.now(),
    );
  }

  String _cleanLine(String line) {
    // Strip common markdown/prefix artifacts tiny models produce
    return line
        .replaceAll(RegExp(r'^\*+\s*'), '')
        .replaceAll(RegExp(r'^-+\s*'), '')
        .replaceAll(RegExp(r'^\d+\.\s*'), '')
        .trim();
  }

  void _assertOk(http.Response resp) {
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(
          'AI API error ${resp.statusCode}: ${resp.body.substring(0, resp.body.length.clamp(0, 200))}');
    }
  }
}
