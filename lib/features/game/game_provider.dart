import 'package:flutter/material.dart';
import '../../core/config/ai_config.dart';
import '../../core/models/ai_insight.dart';
import '../../core/models/ai_model.dart';
import '../../core/models/word_model.dart';
import '../../core/models/player_stats_model.dart';
import '../../core/models/game_history_model.dart';
import '../../core/models/guess_result.dart';
import '../../core/models/active_game_model.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/insight_cache_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/word_service.dart';
import '../../core/services/audio_service.dart';
import 'game_engine.dart';

enum GameMode { classic, custom, rage }

class GameProvider extends ChangeNotifier {
  final StorageService storage;
  final WordService wordService;
  final InsightCacheService insightCache;
  final AudioService audioService = AudioService();

  GameProvider({
    required this.storage,
    required this.wordService,
    required this.insightCache,
  });

  // ── Game State ────────────────────────────────────────────────
  GameEngine? _engine;
  GameMode _mode = GameMode.classic;
  PlayerStatsModel? _stats;
  bool _isDarkMode = false;  // light mode is default

  // Rage mode
  int _rageModeLives = 3;
  int _rageModeCurrentLives = 3;
  Set<String> _rageUsedWords = {};
  int _rageStreak = 0;

  // Custom mode
  int _customWordLength = 5;
  int _customAttempts = 6;
  List<WordModel>? _customWordPool;

  // Animation triggers
  bool _shakeTrigger = false;
  bool _revealTrigger = false;
  int? _lastRevealedRow;

  // ── AI State ──────────────────────────────────────────────────
  AiModel? _selectedModel;
  AiService? _aiService;
  bool _wordValidationEnabled = false;  // OFF by default
  bool _insightsEnabled = true;
  bool _isValidating = false;
  bool _isInsightLoading = false;
  AiInsight? _lastInsight;
  String _ollamaUrl = AiConfig.ollamaDefaultUrl;

  // Not-a-word signal (for UI toast)
  bool _invalidWordFlag = false;
  
  // AI Logs and GGUF
  final List<Map<String, String>> _aiLogs = [];
  String _ggufPath = '';

  // ── Getters — Game ────────────────────────────────────────────
  GameEngine? get engine => _engine;
  GameMode get mode => _mode;
  PlayerStatsModel get stats => _stats ?? PlayerStatsModel();
  bool get isDarkMode => _isDarkMode;
  int get rageLives => _rageModeCurrentLives;
  int get rageStreak => _rageStreak;
  int get customWordLength => _customWordLength;
  int get customAttempts => _customAttempts;
  List<WordModel> get customWords => wordService.getCustomWords();
  bool get shakeTrigger => _shakeTrigger;
  bool get revealTrigger => _revealTrigger;
  int? get lastRevealedRow => _lastRevealedRow;

  // ── Getters — AI ──────────────────────────────────────────────
  AiModel? get selectedModel => _selectedModel;
  bool get wordValidationEnabled => _wordValidationEnabled;
  bool get insightsEnabled => _insightsEnabled;
  bool get isValidating => _isValidating;
  bool get isInsightLoading => _isInsightLoading;
  AiInsight? get lastInsight => _lastInsight;
  bool get invalidWordFlag => _invalidWordFlag;
  String get ollamaUrl => _ollamaUrl;
  int get cachedInsightCount => insightCache.count;
  bool get hasAiService => _aiService != null;
  bool get hasActiveGame => _engine != null && !_engine!.isGameOver;
  int get totalAvailableWords => storage.getDefaultWords().length;
  int get playedWordsCount => storage.getUsedWords().length;
  
  List<Map<String, String>> get aiLogs => _aiLogs;
  String get ggufPath => _ggufPath;

  // ── Initialization ────────────────────────────────────────────
  Future<void> init() async {
    await audioService.init();
    await wordService.seedWords();
    _stats = storage.getStats();

    // Load persisted settings
    _isDarkMode = storage.getSetting('dark_mode', fallback: 'false') == 'true';
    _wordValidationEnabled = storage.getSetting('word_validation', fallback: 'false') == 'true';
    _insightsEnabled = storage.getSetting('insights_enabled', fallback: 'false') == 'true';
    _ollamaUrl = storage.getSetting('ollama_url', fallback: AiConfig.ollamaDefaultUrl);
    _ggufPath = storage.getSetting('gguf_path', fallback: '');

    // Restore active game state if it exists
    final savedGame = storage.getActiveGame();
    if (savedGame != null) {
      _mode = GameMode.values.firstWhere((e) => e.name == savedGame.gameMode, orElse: () => GameMode.classic);
      _rageModeCurrentLives = savedGame.rageLives;
      _engine = GameEngine(targetWord: WordModel.fromString(savedGame.targetWord), maxAttempts: savedGame.maxAttempts);
      for (final g in savedGame.guesses) {
        for (final char in g.split('')) {
          _engine!.addLetter(char);
        }
        _engine!.submitGuess();
      }
      for (final char in savedGame.currentInput.split('')) {
        _engine!.addLetter(char);
      }
    }

    // Seed dev keys from AiConfig (only if not yet set)
    _seedDevKey('gemini', AiConfig.geminiKey);
    _seedDevKey('anthropic', AiConfig.anthropicKey);
    _seedDevKey('openai', AiConfig.openaiKey);
    _seedDevKey('groq', AiConfig.groqKey);
    _seedDevKey('openrouter', AiConfig.openrouterKey);

    // Restore selected model
    final savedModelId = storage.getSetting('selected_model');
    if (savedModelId.isNotEmpty) {
      final model = AiModels.findById(savedModelId);
      if (model != null) {
        _selectedModel = model;
        _rebuildAiService();
      }
    }

    // Default to Gemini Flash if a key is available and no model selected
    if (_selectedModel == null && getApiKey('gemini').isNotEmpty) {
      _selectedModel = AiModels.geminiFlash20;
      _rebuildAiService();
    }

    notifyListeners();
  }

  void _seedDevKey(String providerId, String configKey) {
    if (configKey.isEmpty) return;
    final stored = storage.getSetting('key_$providerId');
    if (stored.isEmpty) {
      storage.putSetting('key_$providerId', configKey);
    }
  }

  void _rebuildAiService() {
    if (_selectedModel == null) {
      _aiService = null;
      return;
    }
    final model = _selectedModel!;
    final key = getApiKey(model.settingsKeyId);
    final url = model.isLocal ? _ollamaUrl : model.endpoint;

    if (!model.isLocal && key.isEmpty) {
      _aiService = null;
      return;
    }

    _aiService = AiService(
      model: model.isLocal
          ? AiModel(
              id: model.id,
              displayName: model.displayName,
              subtitle: model.subtitle,
              provider: model.provider,
              modelId: model.modelId,
              endpoint: url,
              color: model.color,
              isFree: model.isFree,
              isLocal: model.isLocal,
            )
          : model,
      apiKey: key,
      ggufPath: _ggufPath,
    );
  }

  // ── Theme ─────────────────────────────────────────────────────
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    storage.putSetting('dark_mode', _isDarkMode.toString());
    notifyListeners();
  }

  // ── AI Settings ───────────────────────────────────────────────
  String getApiKey(String providerId) =>
      storage.getSetting('key_$providerId');

  Future<void> saveApiKey(String providerId, String key) async {
    await storage.putSetting('key_$providerId', key.trim());
    _rebuildAiService();
    notifyListeners();
  }

  void selectModel(AiModel model) {
    _selectedModel = model;
    storage.putSetting('selected_model', model.id);
    _rebuildAiService();
    notifyListeners();
  }

  void setWordValidation(bool enabled) {
    _wordValidationEnabled = enabled;
    storage.putSetting('word_validation', enabled.toString());
    notifyListeners();
  }

  void setInsights(bool enabled) {
    _insightsEnabled = enabled;
    storage.putSetting('insights_enabled', enabled.toString());
    notifyListeners();
  }

  void setOllamaUrl(String url) {
    _ollamaUrl = url.trim();
    storage.putSetting('ollama_url', _ollamaUrl);
    _rebuildAiService();
  }

  void setGgufPath(String path) {
    _ggufPath = path;
    storage.putSetting('gguf_path', path);
    _rebuildAiService();
    notifyListeners();
  }

  void addAiLog(String prompt, String response) {
    _aiLogs.add({'prompt': prompt, 'response': response});
    notifyListeners();
  }

  void clearAiLogs() {
    _aiLogs.clear();
    notifyListeners();
  }

  Future<void> clearInsightCache() async {
    await insightCache.clearAll();
    _lastInsight = null;
    notifyListeners();
  }

  // ── Game Start ────────────────────────────────────────────────
  void startClassicMode() {
    _mode = GameMode.classic;
    _lastInsight = null;
    final streak = _stats?.currentStreak ?? 0;
    final word = wordService.selectWord(streak: streak, mode: 'classic');
    if (word == null) return;
    final attempts =
        wordService.calculateAttempts(word.length, streakModifier: streak);
    _engine = GameEngine(targetWord: word, maxAttempts: attempts);
    _resetAnimTriggers();
    _prewarmInsight(word.text);
    notifyListeners();
  }

  void startCustomMode({List<WordModel>? pool}) {
    _mode = GameMode.custom;
    _lastInsight = null;
    _customWordPool = pool ?? wordService.getCustomWords();
    if (_customWordPool!.isEmpty) return;
    final word = wordService.selectWord(
      streak: 0,
      mode: 'custom',
      customPool: _customWordPool,
      forcedLength: _customWordLength,
    );
    if (word == null) return;
    _engine = GameEngine(targetWord: word, maxAttempts: _customAttempts);
    _resetAnimTriggers();
    _prewarmInsight(word.text);
    notifyListeners();
  }

  int _rageDifficulty = 2; // Default to medium

  void startRageMode({int difficulty = 2}) {
    _mode = GameMode.rage;
    _rageDifficulty = difficulty;
    _lastInsight = null;
    _rageModeCurrentLives = 3;
    _rageUsedWords = {};
    _rageStreak = 0;
    _startNextRageRound();
  }

  void _startNextRageRound() {
    final allWords = wordService.getRagePool(_rageDifficulty);
    final available =
        allWords.where((w) => !_rageUsedWords.contains(w.text)).toList();
    final pool = available.isEmpty ? allWords : available;
    final double diffScore = (1.0 + (_rageStreak / 3.0)).clamp(1.0, 3.0);
    final targetDiff = diffScore.round();
    final candidates =
        pool.where((w) => (w.difficulty - targetDiff).abs() <= 1).toList();
    final finalPool = candidates.isNotEmpty ? candidates : pool;
    if (finalPool.isEmpty) return;
    final word =
        finalPool[DateTime.now().millisecondsSinceEpoch % finalPool.length];
    _rageUsedWords.add(word.text);
    final attempts = wordService.calculateAttempts(word.length,
        streakModifier: _rageStreak ~/ 2);
    _engine = GameEngine(targetWord: word, maxAttempts: attempts);
    _resetAnimTriggers();
    notifyListeners();
    _saveActiveState();
  }

  Future<void> _saveActiveState() async {
    if (_engine == null || _engine!.isGameOver) {
      await storage.clearActiveGame();
      return;
    }
    final model = ActiveGameModel(
      targetWord: _engine!.target,
      guesses: _engine!.guessHistory.map((g) => g.letters.map((l) => l.letter).join('')).toList(),
      currentInput: _engine!.currentGuess,
      gameMode: _mode.name,
      maxAttempts: _engine!.maxAttempts,
      rageLives: _rageModeCurrentLives,
    );
    await storage.saveActiveGame(model);
  }

  // ── Input Handling ────────────────────────────────────────────
  void onKeyPressed(String key) {
    if (_engine == null || _engine!.isGameOver) return;
    audioService.playTyping();
    _engine!.addLetter(key);
    // Clear invalid flag when typing
    if (_invalidWordFlag) {
      _invalidWordFlag = false;
    }
    _saveActiveState();
    notifyListeners();
  }

  void onBackspace() {
    if (_engine == null || _engine!.isGameOver) return;
    audioService.playTyping();
    _engine!.removeLetter();
    _saveActiveState();
    notifyListeners();
  }

  Future<void> onEnter() async {
    if (_engine == null || _engine!.isGameOver) return;
    if (_engine!.currentGuess.length != _engine!.wordLength) {
      _triggerShake();
      return;
    }

    // ── AI Word Validation (opt-in, off by default) ──────────────
    if (_wordValidationEnabled && _aiService != null) {
      _isValidating = true;
      _invalidWordFlag = false;
      notifyListeners();

      final isReal = await _aiService!.validateWord(_engine!.currentGuess);

      _isValidating = false;
      notifyListeners();

      if (!isReal) {
        _invalidWordFlag = true;
        _triggerShake();
        // Auto-clear the flag after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          _invalidWordFlag = false;
          notifyListeners();
        });
        return;
      }
    }

    // ── Submit guess ─────────────────────────────────────────────
    final result = _engine!.submitGuess();
    if (result == null) return;

    _lastRevealedRow = _engine!.attemptsUsed - 1;
    _revealTrigger = !_revealTrigger;

    // Zero-latency Audio Tracking
    if (_engine!.status == GameStatus.won) {
      audioService.playWin();
    } else if (_engine!.status == GameStatus.lost) {
      if (_mode == GameMode.rage) {
        audioService.playRageLose();
      } else {
        audioService.playLose();
      }
    } else {
      Set<int> previousCorrectIndices = {};
      if (_engine!.guessHistory.length > 1) {
        for (int i = 0; i < _engine!.guessHistory.length - 1; i++) {
          for (int j = 0; j < _engine!.guessHistory[i].letters.length; j++) {
            if (_engine!.guessHistory[i].letters[j].status == LetterStatus.correct) {
              previousCorrectIndices.add(j);
            }
          }
        }
      }
      
      bool foundNewGreen = false;
      for (int i = 0; i < result.letters.length; i++) {
        if (result.letters[i].status == LetterStatus.correct && !previousCorrectIndices.contains(i)) {
          foundNewGreen = true;
          break;
        }
      }

      if (foundNewGreen) {
        audioService.playCorrect();
      } else {
        audioService.playWrong();
      }
    }

    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    // Post-audio routing / cleanup state actions
    if (_engine!.status == GameStatus.won) {
      await storage.clearActiveGame();
      await _handleWin();
    } else if (_engine!.status == GameStatus.lost) {
      await storage.clearActiveGame();
      await _handleLoss();
    } else {
      _saveActiveState();
    }

    // ── Post-game AI insight ─────────────────────────────────────
    if (_engine!.isGameOver && _insightsEnabled && _aiService != null) {
      _fetchInsight(_engine!.target);
    }

    notifyListeners();
  }

  Future<void> abandonRageLevel() async {
    if (_mode != GameMode.rage || _engine == null || _engine!.isGameOver) return;
    _engine!.status = GameStatus.lost;
    audioService.playRageLose();
    await storage.clearActiveGame();
    await _handleLoss();
    if (_insightsEnabled && _aiService != null) {
      _fetchInsight(_engine!.target);
    }
    notifyListeners();
  }

  Future<void> _fetchInsight(String word) async {
    // Check cache first — no network call needed
    final cached = insightCache.get(word);
    if (cached != null) {
      _lastInsight = cached;
      addAiLog('Insight Cache Hit ($word)', 'Success:\n${cached.definition}\n${cached.fact}');
      notifyListeners();
      return;
    }

    _isInsightLoading = true;
    notifyListeners();

    try {
      final insight = await _aiService?.analyzeWord(word);
      _isInsightLoading = false;
      if (insight != null) {
        _lastInsight = insight;
        await insightCache.store(insight); // persist permanently
        addAiLog('Insight ($word)', 'Success:\n${insight.definition}');
      }
    } catch (e) {
      _isInsightLoading = false;
      addAiLog('Insight ($word)', 'ERROR: $e');
    }

    notifyListeners();
  }

  /// Fire-and-forget: pre-warm insight cache at game start so result
  /// modal shows instantly when the game ends.
  void _prewarmInsight(String word) {
    if (!_insightsEnabled || _aiService == null) return;
    if (insightCache.has(word)) return; // already cached, nothing to do
    _aiService!.analyzeWord(word).then((insight) {
      if (insight != null) {
        insightCache.store(insight);
        addAiLog('Prewarm Engine ($word)', 'Success:\n${insight.definition}\n${insight.fact}');
      }
    }).catchError((e) {
      addAiLog('Prewarm Insight ($word)', 'ERROR: $e');
    });
  }

  // ── Win / Loss ────────────────────────────────────────────────
  Future<void> _handleWin() async {
    final attemptsUsed = _engine!.attemptsUsed;
    final word = _engine!.target;
    await storage.markWordUsed(word);
    _stats ??= PlayerStatsModel();
    _stats!.recordWin(attemptsUsed);
    await storage.saveStats(_stats!);
    await storage.addHistory(GameHistoryModel(
      word: word,
      mode: _mode.name,
      won: true,
      attemptsUsed: attemptsUsed,
      playedAt: DateTime.now(),
    ));
    if (_mode == GameMode.rage) _rageStreak++;
  }

  Future<void> _handleLoss() async {
    final word = _engine!.target;
    await storage.markWordUsed(word);
    _stats ??= PlayerStatsModel();
    _stats!.recordLoss();
    await storage.saveStats(_stats!);
    await storage.addHistory(GameHistoryModel(
      word: word,
      mode: _mode.name,
      won: false,
      attemptsUsed: _engine!.attemptsUsed,
      playedAt: DateTime.now(),
    ));
    if (_mode == GameMode.rage) {
      _rageModeCurrentLives--;
      if (_rageModeCurrentLives <= 0) {
        _stats!.totalRageRuns++;
        await storage.saveStats(_stats!);
      }
    }
  }

  // ── Rage Continuation ─────────────────────────────────────────
  void continueRage() {
    if (_rageModeCurrentLives > 0) _startNextRageRound();
  }

  // ── Restart ───────────────────────────────────────────────────
  void restartGame() {
    switch (_mode) {
      case GameMode.classic:
        startClassicMode();
        break;
      case GameMode.custom:
        startCustomMode();
        break;
      case GameMode.rage:
        startRageMode();
        break;
    }
  }

  // ── Custom Config ─────────────────────────────────────────────
  void setCustomWordLength(int length) {
    _customWordLength = length;
    notifyListeners();
  }

  void setCustomAttempts(int attempts) {
    _customAttempts = attempts;
    notifyListeners();
  }

  Future<void> addCustomWord(String word) async {
    await wordService.addCustomWord(word);
    notifyListeners();
  }

  Future<void> deleteCustomWord(int index) async {
    await wordService.deleteCustomWord(index);
    notifyListeners();
  }

  Future<void> clearCustomWords() async {
    await wordService.clearCustomWords();
    notifyListeners();
  }

  // ── Animation Helpers ─────────────────────────────────────────
  void _triggerShake() {
    _shakeTrigger = !_shakeTrigger;
    notifyListeners();
  }

  void _resetAnimTriggers() {
    _shakeTrigger = false;
    _revealTrigger = false;
    _lastRevealedRow = null;
    _invalidWordFlag = false;
  }
}
