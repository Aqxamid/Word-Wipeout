// lib/ui/widgets/result_modal.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../features/game/game_engine.dart';
import '../../features/game/game_provider.dart';
import '../theme/app_theme.dart';
import 'ai_insight_panel.dart';

class ResultModal extends StatefulWidget {
  final GameEngine engine;
  final GameMode mode;
  final int streak;
  final int rageLives;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;
  final VoidCallback? onContinueRage;

  const ResultModal({
    super.key,
    required this.engine,
    required this.mode,
    required this.streak,
    required this.rageLives,
    required this.onPlayAgain,
    required this.onHome,
    this.onContinueRage,
  });

  @override
  State<ResultModal> createState() => _ResultModalState();
}

class _ResultModalState extends State<ResultModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isWin => widget.engine.status == GameStatus.won;
  bool get _isRageOver =>
      widget.mode == GameMode.rage && widget.rageLives <= 0 && !_isWin;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        color: (context.isDark ? AppColors.darkSurface : AppColors.lightSurface)
            .withOpacity(0.6),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnim,
            child: _buildCard(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.darkSurfaceContainerHigh.withOpacity(0.9)
            : AppColors.lightSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: context.outlineVariant.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: -5,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGlowAccent(context),
          const SizedBox(height: 8),
          _buildIcon(context),
          const SizedBox(height: 16),
          _buildHeadline(context),
          const SizedBox(height: 6),
          _buildSubtitle(context),
          const SizedBox(height: 24),
          _buildWordDisplay(context),
          const SizedBox(height: 24),
          _buildStats(context),
          const SizedBox(height: 24),
          _buildActions(context),
          // AI insight panel — shows after game ends
          Consumer<GameProvider>(
            builder: (_, provider, __) => AiInsightPanel(
              insight: provider.lastInsight,
              isLoading: provider.isInsightLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowAccent(BuildContext context) {
    return Container(
      width: 80,
      height: 4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isWin
              ? [context.tertiary.withOpacity(0.3), context.primaryColor]
              : [context.errorColor.withOpacity(0.3), context.errorColor],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: _isWin
            ? context.tertiary.withOpacity(0.12)
            : context.errorColor.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _isWin ? Icons.stars_rounded : Icons.sentiment_dissatisfied_rounded,
        size: 40,
        color: _isWin ? context.tertiary : context.errorColor,
      ),
    );
  }

  Widget _buildHeadline(BuildContext context) {
    String title;
    if (_isRageOver) {
      title = 'RAGE OVER';
    } else if (_isWin) {
      title = 'YOU WIN!';
    } else {
      title = 'GAME OVER';
    }

    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: context.onSurface,
        letterSpacing: -1,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    String sub;
    if (_isWin) {
      sub = widget.mode == GameMode.rage
          ? 'Round cleared! Keep going.'
          : 'The curator is impressed.';
    } else if (_isRageOver) {
      sub = 'All lives lost. The word was:';
    } else {
      sub = 'The word was:';
    }

    return Text(
      sub,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: context.onSurfaceVariant,
      ),
    );
  }

  Widget _buildWordDisplay(BuildContext context) {
    final letters = widget.engine.target.split('');
    return LayoutBuilder(
      builder: (context, constraints) {
        // Each tile: 44px wide + 6px total margin. Calculate if it fits.
        final needed = letters.length * 50.0;
        final scale = needed > constraints.maxWidth
            ? constraints.maxWidth / needed
            : 1.0;
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: letters.map((letter) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 44,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'ATTEMPTS',
            value: '${widget.engine.attemptsUsed} / ${widget.engine.maxAttempts}',
            context: context,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'LEVEL',
            value: '${widget.streak}',
            trailing: Icon(Icons.star_rounded,
                color: context.tertiary, size: 20),
            context: context,
          ),
        ),
        if (widget.mode == GameMode.rage) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'LIVES',
              value: '${widget.rageLives}',
              trailing: Icon(Icons.favorite_rounded,
                  color: context.errorColor, size: 20),
              context: context,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        // Primary action
        SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.primaryColor, context.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
              ),
              onPressed: widget.mode == GameMode.rage &&
                      (_isWin || widget.rageLives > 0) &&
                      widget.onContinueRage != null
                  ? widget.onContinueRage
                  : widget.onPlayAgain,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (widget.mode == GameMode.rage || widget.mode == GameMode.classic) && _isWin
                        ? 'Next Level'
                        : (widget.mode == GameMode.rage && !_isWin && widget.rageLives > 0)
                            ? 'Revive'
                            : 'Play Again',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: context.isDark
                          ? AppColors.darkOnPrimaryContainer
                          : AppColors.lightOnPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    widget.mode == GameMode.rage && _isWin
                        ? Icons.arrow_forward_rounded
                        : Icons.refresh_rounded,
                    color: context.isDark
                        ? AppColors.darkOnPrimaryContainer
                        : AppColors.lightOnPrimaryContainer,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Secondary
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: context.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
            onPressed: widget.onHome,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Change Mode',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.tune_rounded, color: context.onSurfaceVariant, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  final BuildContext context;

  const _StatCard({
    required this.label,
    required this.value,
    required this.context,
    this.trailing,
  });

  @override
  Widget build(BuildContext outerContext) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: outerContext.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: outerContext.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: outerContext.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 4),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
