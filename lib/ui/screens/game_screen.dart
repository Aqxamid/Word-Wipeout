// lib/ui/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../features/game/game_engine.dart';
import '../../features/game/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/game_grid.dart';
import '../widgets/game_keyboard.dart';
import '../widgets/result_modal.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final engine = provider.engine;

    if (engine == null) {
      return Scaffold(
        backgroundColor: context.isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No game started.',
                style: GoogleFonts.plusJakartaSans(
                    color: context.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.5 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.primaryColor.withOpacity(0.04),
              ),
            ),
          ),
          Column(
            children: [
              _buildTopBar(context, provider, engine),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: GameGrid(
                      engine: engine,
                      shakeTrigger: provider.shakeTrigger,
                      revealTrigger: provider.revealTrigger,
                      lastRevealedRow: provider.lastRevealedRow,
                    ),
                  ),
                ),
              ),
              GameKeyboard(
                keyStates: engine.keyboardState,
                onEnter: () => provider.onEnter(),
                onBackspace: provider.onBackspace,
                onLetter: provider.onKeyPressed,
              ),
              // AI validation banner
              _AiValidationBanner(
                isValidating: provider.isValidating,
                isInvalidWord: provider.invalidWordFlag,
              ),
            ],
          ),
          // Result overlay
          if (engine.isGameOver)
            ResultModal(
              engine: engine,
              mode: provider.mode,
              streak: provider.stats.currentStreak,
              rageLives: provider.rageLives,
              onPlayAgain: () {
                provider.restartGame();
              },
              onHome: () => Navigator.pop(context),
              onContinueRage: provider.mode == GameMode.rage
                  ? () => provider.continueRage()
                  : null,
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, GameProvider provider, GameEngine engine) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_rounded,
                    color: context.onSurface, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            // Title + mode
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Word Wipeout',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: context.primaryColor,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  _modeLabel(provider.mode),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: context.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Mode-specific status
            if (provider.mode == GameMode.rage) ...[
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: context.surfaceContainerHigh,
                      title: Text('Give up?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: context.onSurface)),
                      content: Text('You will lose 1 life and forfeit this match. Are you sure?', style: GoogleFonts.plusJakartaSans(color: context.onSurfaceVariant)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: context.primaryColor)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            provider.abandonRageLevel();
                          },
                          child: Text('Forfeit', style: GoogleFonts.plusJakartaSans(color: context.errorColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: context.errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.flag_rounded, color: context.errorColor, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              _RageLivesWidget(lives: provider.rageLives)
            ],
            if (provider.mode == GameMode.classic)
              _AttemptsWidget(
                used: engine.attemptsUsed,
                max: engine.maxAttempts,
                context: context,
              ),
            const SizedBox(width: 10),
            // Level
            _LevelBadge(level: provider.stats.currentStreak, context: context),
          ],
        ),
      ),
    );
  }

  String _modeLabel(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return 'CLASSIC';
      case GameMode.custom:
        return 'CUSTOM';
      case GameMode.rage:
        return 'RAGE';
    }
  }
}

class _RageLivesWidget extends StatelessWidget {
  final int lives;

  const _RageLivesWidget({required this.lives});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final active = i < lives;
        return Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Icon(
            active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: active
                ? context.errorColor
                : context.onSurfaceVariant.withOpacity(0.3),
            size: 18,
          ),
        );
      }),
    );
  }
}

class _AttemptsWidget extends StatelessWidget {
  final int used;
  final int max;
  final BuildContext context;

  const _AttemptsWidget({
    required this.used,
    required this.max,
    required this.context,
  });

  @override
  Widget build(BuildContext outerContext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: outerContext.surfaceContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '$used/$max',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: outerContext.onSurface,
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final BuildContext context;

  const _LevelBadge({required this.level, required this.context});

  @override
  Widget build(BuildContext outerContext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: outerContext.surfaceContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Level $level',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: outerContext.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star_rounded, color: outerContext.tertiary, size: 14),
        ],
      ),
    );
  }
}

// ── AI Validation Banner ──────────────────────────────────────────

class _AiValidationBanner extends StatelessWidget {
  final bool isValidating;
  final bool isInvalidWord;

  const _AiValidationBanner({
    required this.isValidating,
    required this.isInvalidWord,
  });

  @override
  Widget build(BuildContext context) {
    if (!isValidating && !isInvalidWord) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isInvalidWord
                ? context.errorColor.withOpacity(0.12)
                : context.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isInvalidWord
                  ? context.errorColor.withOpacity(0.4)
                  : context.primaryColor.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isValidating)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: context.primaryColor,
                  ),
                )
              else
                Icon(Icons.warning_amber_rounded,
                    size: 14, color: context.errorColor),
              const SizedBox(width: 8),
              Text(
                isValidating ? 'AI checking word…' : 'Not a real word',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isInvalidWord
                      ? context.errorColor
                      : context.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
