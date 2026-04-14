// lib/core/models/guess_result.dart

enum LetterStatus { correct, partial, incorrect, empty }

class LetterResult {
  final String letter;
  final LetterStatus status;

  const LetterResult({required this.letter, required this.status});
}

class GuessResult {
  final List<LetterResult> letters;
  final bool isWin;

  const GuessResult({required this.letters, required this.isWin});

  int get correctCount => letters.where((l) => l.status == LetterStatus.correct).length;
}
