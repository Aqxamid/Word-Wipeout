// lib/features/game/game_engine.dart
import '../../core/models/guess_result.dart';
import '../../core/models/word_model.dart';

enum GameStatus { idle, playing, won, lost }

class GameEngine {
  final WordModel targetWord;
  final int maxAttempts;

  final List<GuessResult> guessHistory = [];
  String currentGuess = '';
  GameStatus status = GameStatus.playing;

  // Track letter statuses for keyboard coloring
  final Map<String, LetterStatus> keyboardState = {};

  GameEngine({required this.targetWord, required this.maxAttempts});

  String get target => targetWord.text;
  int get wordLength => targetWord.length;
  int get attemptsUsed => guessHistory.length;
  int get attemptsRemaining => maxAttempts - attemptsUsed;
  bool get isGameOver => status == GameStatus.won || status == GameStatus.lost;

  void addLetter(String letter) {
    if (isGameOver) return;
    if (currentGuess.length < wordLength) {
      currentGuess += letter.toUpperCase();
    }
  }

  void removeLetter() {
    if (isGameOver) return;
    if (currentGuess.isNotEmpty) {
      currentGuess = currentGuess.substring(0, currentGuess.length - 1);
    }
  }

  /// Returns a GuessResult if the guess is valid length, null otherwise.
  GuessResult? submitGuess() {
    if (isGameOver) return null;
    if (currentGuess.length != wordLength) return null;

    final result = _evaluate(currentGuess);
    guessHistory.add(result);
    _updateKeyboardState(result);

    if (result.isWin) {
      status = GameStatus.won;
    } else if (attemptsUsed >= maxAttempts) {
      status = GameStatus.lost;
    }

    currentGuess = '';
    return result;
  }

  GuessResult _evaluate(String guess) {
    final guessLetters = guess.split('');
    final targetLetters = target.split('');
    final results = List<LetterStatus>.filled(wordLength, LetterStatus.incorrect);

    // Track remaining target letters (after removing exact matches)
    final remaining = List<String?>.from(targetLetters);

    // First pass: exact matches (correct position)
    for (int i = 0; i < wordLength; i++) {
      if (guessLetters[i] == targetLetters[i]) {
        results[i] = LetterStatus.correct;
        remaining[i] = null;
      }
    }

    // Second pass: partial matches (wrong position)
    for (int i = 0; i < wordLength; i++) {
      if (results[i] == LetterStatus.correct) continue;
      final idx = remaining.indexOf(guessLetters[i]);
      if (idx != -1) {
        results[i] = LetterStatus.partial;
        remaining[idx] = null;
      }
    }

    final letterResults = List.generate(
      wordLength,
      (i) => LetterResult(letter: guessLetters[i], status: results[i]),
    );

    final isWin = results.every((s) => s == LetterStatus.correct);
    return GuessResult(letters: letterResults, isWin: isWin);
  }

  void _updateKeyboardState(GuessResult result) {
    for (final letter in result.letters) {
      final current = keyboardState[letter.letter];
      // Only upgrade status, never downgrade
      if (current == null || _statusPriority(letter.status) > _statusPriority(current)) {
        keyboardState[letter.letter] = letter.status;
      }
    }
  }

  int _statusPriority(LetterStatus s) {
    switch (s) {
      case LetterStatus.correct: return 3;
      case LetterStatus.partial: return 2;
      case LetterStatus.incorrect: return 1;
      case LetterStatus.empty: return 0;
    }
  }
}
