// lib/ui/widgets/game_tile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/guess_result.dart';
import '../theme/app_theme.dart';

class GameTile extends StatefulWidget {
  final String letter;
  final LetterStatus status;
  final bool isActive;
  final int animationDelay;
  final bool animate;

  const GameTile({
    super.key,
    required this.letter,
    required this.status,
    this.isActive = false,
    this.animationDelay = 0,
    this.animate = false,
  });

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnim;
  late Animation<double> _scaleAnim;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 1),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(GameTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      Future.delayed(Duration(milliseconds: widget.animationDelay), () {
        if (mounted) {
          _controller.forward(from: 0).then((_) {
            if (mounted) setState(() => _showBack = true);
          });
        }
      });
    }
    if (!widget.animate && oldWidget.animate) {
      setState(() => _showBack = false);
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Wordle standard: GREEN = correct position, YELLOW = wrong position
  static const Color _correctGreen = Color(0xFF22C55E);
  static const Color _partialYellow = Color(0xFFEAB308);

  Color _getStatusColor(BuildContext context) {
    switch (widget.status) {
      case LetterStatus.correct:
        return _correctGreen;
      case LetterStatus.partial:
        return _partialYellow;
      case LetterStatus.incorrect:
        return context.surfaceContainerHighest;
      case LetterStatus.empty:
        return context.surfaceContainerLowest;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (widget.status) {
      case LetterStatus.correct:
        return Colors.white;
      case LetterStatus.partial:
        return const Color(0xFF1A1200); // dark text on yellow
      case LetterStatus.incorrect:
        return context.onSurface;
      case LetterStatus.empty:
        return context.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = _showBack || !widget.animate
        ? widget.status
        : LetterStatus.empty;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.letter.isNotEmpty && !widget.animate
              ? 1.0
              : _scaleAnim.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: _getStatusColor(context).withOpacity(
                  effectiveStatus == LetterStatus.empty ? 1.0 : 1.0),
              borderRadius: BorderRadius.circular(10),
              border: widget.isActive
                  ? Border.all(
                      color: context.primaryColor.withOpacity(0.7), width: 2)
                  : widget.letter.isEmpty
                      ? Border.all(
                          color: context.outlineVariant.withOpacity(0.15),
                          width: 1)
                      : effectiveStatus == LetterStatus.empty
                          ? Border.all(
                              color: context.outlineVariant.withOpacity(0.25),
                              width: 1.5)
                          : null,
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: context.primaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 0,
                      )
                    ]
                  : effectiveStatus == LetterStatus.correct
                      ? [
                          const BoxShadow(
                            color: Color(0x4422C55E),
                            blurRadius: 12,
                            spreadRadius: -2,
                          )
                        ]
                      : effectiveStatus == LetterStatus.partial
                          ? [
                              const BoxShadow(
                                color: Color(0x44EAB308),
                                blurRadius: 12,
                                spreadRadius: -2,
                              )
                            ]
                          : null,
            ),
            child: Center(
              child: Text(
                widget.letter,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: _getTextColor(context),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
