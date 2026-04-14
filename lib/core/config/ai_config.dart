// lib/core/config/ai_config.dart
//
// ╔══════════════════════════════════════════════════════════════╗
// ║  DEVELOPER KEY CONFIG — fill your own keys here for dev.    ║
// ║  These are seeded into Hive on first launch.                ║
// ║  Users can also override them inside the Settings screen.   ║
// ╚══════════════════════════════════════════════════════════════╝
//
// Get a free Gemini key → https://aistudio.google.com/app/apikey
// Get a free Groq key   → https://console.groq.com/keys
// OpenRouter free tier  → https://openrouter.ai/keys
// Anthropic             → https://console.anthropic.com/
// OpenAI                → https://platform.openai.com/api-keys

class AiConfig {
  // ── Google Gemini ─────────────────────────────────────────────
  static const String geminiKey = '';

  // ── Anthropic Claude ──────────────────────────────────────────
  static const String anthropicKey = '';

  // ── OpenAI ───────────────────────────────────────────────────
  static const String openaiKey = '';

  // ── Groq (FREE tier — very fast inference) ────────────────────
  static const String groqKey = '';

  // ── OpenRouter (multiple free models) ────────────────────────
  static const String openrouterKey = '';

  // ── Local Ollama endpoint ─────────────────────────────────────
  // Android emulator → host machine is 10.0.2.2
  // Real device on same WiFi → use your PC's LAN IP, e.g. 192.168.1.x
  // Desktop / Web → localhost
  static const String ollamaDefaultUrl = 'http://10.0.2.2:11434';

  // Default local model to use (must be pulled in Ollama first)
  // Recommended tiny models: tinyllama, qwen2.5:0.5b, llama3.2:1b, phi3:mini
  static const String ollamaDefaultModel = 'tinyllama';
}
