// lib/ui/widgets/game_grid.dart
import 'package:flutter/material.dart';
import '../../core/models/guess_result.dart';
import '../../features/game/game_engine.dart';
import 'game_tile.dart';

class GameGrid extends StatefulWidget {
  final GameEngine engine;
  final bool shakeTrigger;
  final bool revealTrigger;
  final int? lastRevealedRow;

  const GameGrid({
    super.key,
    required this.engine,
    required this.shakeTrigger,
    required this.revealTrigger,
    this.lastRevealedRow,
  });

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  bool _previousShake = false;
  bool _previousReveal = false;
  Set<int> _revealedRows = {};

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(GameGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeTrigger != _previousShake) {
      _previousShake = widget.shakeTrigger;
      _shakeController.forward(from: 0);
    }
    if (widget.revealTrigger != _previousReveal) {
      _previousReveal = widget.revealTrigger;
      if (widget.lastRevealedRow != null) {
        setState(() => _revealedRows.add(widget.lastRevealedRow!));
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final wordLen = engine.wordLength;
    final maxAttempts = engine.maxAttempts;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxAttempts, (row) {
        final isCurrentRow = row == engine.attemptsUsed && !engine.isGameOver;
        final hasGuess = row < engine.guessHistory.length;
        final isRevealingRow = _revealedRows.contains(row);

        return AnimatedBuilder(
          animation: _shakeAnim,
          builder: (context, child) {
            double offset = 0;
            if (isCurrentRow && _shakeController.isAnimating) {
              offset = 8 *
                  (0.5 - (_shakeAnim.value - 0.5).abs()) *
                  (_shakeAnim.value < 0.5 ? 1 : -1);
            }
            return Transform.translate(
              offset: Offset(offset, 0),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(wordLen, (col) {
                String letter = '';
                LetterStatus status = LetterStatus.empty;
                bool isActive = false;

                if (hasGuess) {
                  final guess = engine.guessHistory[row];
                  letter = guess.letters[col].letter;
                  status = isRevealingRow
                      ? guess.letters[col].status
                      : LetterStatus.empty;
                  if (!isRevealingRow && row < engine.guessHistory.length) {
                    // Check if reveal is done (row already revealed before)
                    status = guess.letters[col].status;
                  }
                } else if (isCurrentRow) {
                  if (col < engine.currentGuess.length) {
                    letter = engine.currentGuess[col];
                    status = LetterStatus.empty;
                    isActive = true;
                  }
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: wordLen > 6 ? 3 : 4),
                  child: SizedBox(
                    width: _tileSize(wordLen, context),
                    height: _tileSize(wordLen, context),
                    child: GameTile(
                      key: ValueKey('tile_${row}_$col'),
                      letter: letter,
                      status: status,
                      isActive: isActive,
                      animationDelay: col * 80,
                      animate: false,
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }

  double _tileSize(int wordLen, BuildContext context) {
    final screen = MediaQuery.of(context).size.width;
    final available = screen - 48;
    final gap = (wordLen - 1) * 8.0;
    final size = (available - gap) / wordLen;
    return size.clamp(40.0, 72.0);
  }
}
