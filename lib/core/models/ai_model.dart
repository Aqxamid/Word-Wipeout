// lib/core/models/ai_model.dart
import 'package:flutter/material.dart';

enum AiProvider { google, local }

class AiModel {
  final String id;
  final String displayName;
  final String subtitle;
  final AiProvider provider;
  final String modelId;
  final String endpoint;
  final Color color;
  final bool isFree;
  final bool isLocal;
  final String? contextNote;

  const AiModel({
    required this.id,
    required this.displayName,
    required this.subtitle,
    required this.provider,
    required this.modelId,
    required this.endpoint,
    required this.color,
    this.isFree = false,
    this.isLocal = false,
    this.contextNote,
  });

  String get providerName {
    switch (provider) {
      case AiProvider.google:    return 'Google';
      case AiProvider.local:     return 'Local';
    }
  }

  String get settingsKeyId {
    switch (provider) {
      case AiProvider.google:    return 'gemini';
      case AiProvider.local:     return 'local';
    }
  }
}

// ── All model presets ─────────────────────────────────────────────────────────

class AiModels {
  static const _geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models';


  // ── Google Gemini ─────────────────────────────────────────────
  static const geminiFlash20 = AiModel(
    id: 'gemini-flash-2.0',
    displayName: 'Gemini 2.0 Flash',
    subtitle: 'Fastest · Free tier',
    provider: AiProvider.google,
    modelId: 'gemini-2.0-flash',
    endpoint: _geminiEndpoint,
    color: Color(0xFF4285F4),
    isFree: true,
    contextNote: 'Best default — generous free quota',
  );

  static const geminiFlash20Lite = AiModel(
    id: 'gemini-flash-2.0-lite',
    displayName: 'Gemini 2.0 Flash Lite',
    subtitle: 'Ultra-fast · Free tier',
    provider: AiProvider.google,
    modelId: 'gemini-2.0-flash-lite',
    endpoint: _geminiEndpoint,
    color: Color(0xFF4285F4),
    isFree: true,
  );

  static const geminiPro20 = AiModel(
    id: 'gemini-pro-2.0',
    displayName: 'Gemini 2.0 Pro',
    subtitle: 'High quality',
    provider: AiProvider.google,
    modelId: 'gemini-2.0-pro-exp',
    endpoint: _geminiEndpoint,
    color: Color(0xFF4285F4),
  );

  static const geminiFlash15 = AiModel(
    id: 'gemini-flash-1.5',
    displayName: 'Gemini 1.5 Flash',
    subtitle: 'Stable · Free tier',
    provider: AiProvider.google,
    modelId: 'gemini-1.5-flash',
    endpoint: _geminiEndpoint,
    color: Color(0xFF4285F4),
    isFree: true,
  );

  static const geminiFlash15_8B = AiModel(
    id: 'gemini-flash-1.5-8b',
    displayName: 'Gemini 1.5 Flash 8B',
    subtitle: 'Compact · Free tier',
    provider: AiProvider.google,
    modelId: 'gemini-1.5-flash-8b',
    endpoint: _geminiEndpoint,
    color: Color(0xFF4285F4),
    isFree: true,
  );

  static const geminiPro15 = AiModel(
    id: 'gemini-pro-1.5',
    displayName: 'Gemini 1.5 Pro',
    subtitle: 'Powerful · Free tier',
    provider: AiProvider.google,
    modelId: 'gemini-1.5-pro',
    endpoint: _geminiEndpoint,
    color: Color(0xFF4285F4),
    isFree: true,
  );


  // ── Local Ollama ──────────────────────────────────────────────
  // Run: ollama pull <modelId> on your machine first
  static const localTinyLlama = AiModel(
    id: 'local-tinyllama',
    displayName: 'TinyLlama 1.1B',
    subtitle: 'Local · Offline · 1.1B',
    provider: AiProvider.local,
    modelId: 'tinyllama',
    endpoint: '',          // set at runtime from settings
    color: Color(0xFF22C55E),
    isFree: true,
    isLocal: true,
    contextNote: 'ollama pull tinyllama',
  );

  static const localQwen05B = AiModel(
    id: 'local-qwen2.5-0.5b',
    displayName: 'Qwen 2.5 0.5B',
    subtitle: 'Local · Offline · 500M',
    provider: AiProvider.local,
    modelId: 'qwen2.5:0.5b',
    endpoint: '',
    color: Color(0xFF22C55E),
    isFree: true,
    isLocal: true,
    contextNote: 'ollama pull qwen2.5:0.5b',
  );

  static const localLlama32_1B = AiModel(
    id: 'local-llama3.2-1b',
    displayName: 'Llama 3.2 1B',
    subtitle: 'Local · Offline · 1B',
    provider: AiProvider.local,
    modelId: 'llama3.2:1b',
    endpoint: '',
    color: Color(0xFF22C55E),
    isFree: true,
    isLocal: true,
    contextNote: 'ollama pull llama3.2:1b',
  );

  static const localGemma2B = AiModel(
    id: 'local-gemma-2b',
    displayName: 'Gemma 2B',
    subtitle: 'Local · Offline · 2B',
    provider: AiProvider.local,
    modelId: 'gemma:2b',
    endpoint: '',
    color: Color(0xFF22C55E),
    isFree: true,
    isLocal: true,
    contextNote: 'ollama pull gemma:2b',
  );

  static const localPhi3Mini = AiModel(
    id: 'local-phi3-mini',
    displayName: 'Phi-3 Mini 3.8B',
    subtitle: 'Local · Offline · 3.8B',
    provider: AiProvider.local,
    modelId: 'phi3:mini',
    endpoint: '',
    color: Color(0xFF22C55E),
    isFree: true,
    isLocal: true,
    contextNote: 'ollama pull phi3:mini',
  );

  static const localOrcaMini = AiModel(
    id: 'local-orca-mini',
    displayName: 'Orca Mini 3B',
    subtitle: 'Local · Offline · 3B',
    provider: AiProvider.local,
    modelId: 'orca-mini',
    endpoint: '',
    color: Color(0xFF22C55E),
    isFree: true,
    isLocal: true,
    contextNote: 'ollama pull orca-mini',
  );

  // ── Master ordered list ───────────────────────────────────────
  static const List<AiModel> all = [
    // Google
    geminiFlash20,
    geminiFlash20Lite,
    geminiFlash15,
    geminiFlash15_8B,
    geminiPro15,
    geminiPro20,

    // Local
    localTinyLlama,
    localQwen05B,
    localLlama32_1B,
    localGemma2B,
    localPhi3Mini,
    localOrcaMini,
  ];

  static AiModel? findById(String id) {
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
