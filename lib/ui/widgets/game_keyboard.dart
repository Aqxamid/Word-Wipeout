// lib/ui/widgets/game_keyboard.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/guess_result.dart';
import '../theme/app_theme.dart';

class GameKeyboard extends StatelessWidget {
  final Map<String, LetterStatus> keyStates;
  final VoidCallback onEnter;
  final VoidCallback onBackspace;
  final void Function(String) onLetter;

  static const _rows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
  ];

  const GameKeyboard({
    super.key,
    required this.keyStates,
    required this.onEnter,
    required this.onBackspace,
    required this.onLetter,
  });

  static const Color _correctGreen = Color(0xFF22C55E);
  static const Color _partialYellow = Color(0xFFEAB308);

  Color _keyBg(String key, BuildContext context) {
    final status = keyStates[key];
    if (status == null) return context.surfaceContainer;
    switch (status) {
      case LetterStatus.correct:
        return _correctGreen;
      case LetterStatus.partial:
        return _partialYellow;
      case LetterStatus.incorrect:
        return context.surfaceContainerHighest;
      case LetterStatus.empty:
        return context.surfaceContainer;
    }
  }

  Color _keyText(String key, BuildContext context) {
    final status = keyStates[key];
    if (status == LetterStatus.correct) return Colors.white;
    if (status == LetterStatus.partial) return const Color(0xFF1A1200);
    return context.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.darkBackground.withOpacity(0.92)
            : AppColors.lightBackground.withOpacity(0.95),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((key) {
                  final isSpecial = key == 'ENTER' || key == '⌫';
                  return Expanded(
                    flex: isSpecial ? 15 : 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: _KeyButton(
                        label: key,
                        isSpecial: isSpecial,
                        bgColor: isSpecial
                            ? context.surfaceContainerHigh
                            : _keyBg(key, context),
                        textColor: isSpecial
                            ? context.onSurface
                            : _keyText(key, context),
                        onTap: () {
                          if (key == 'ENTER') {
                            onEnter();
                          } else if (key == '⌫') {
                            onBackspace();
                          } else {
                            onLetter(key);
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _KeyButton extends StatefulWidget {
  final String label;
  final bool isSpecial;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _KeyButton({
    required this.label,
    required this.isSpecial,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        height: 52,
        decoration: BoxDecoration(
          color: _pressed
              ? widget.bgColor.withOpacity(0.7)
              : widget.bgColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 2),
              blurRadius: 3,
            )
          ],
        ),
        child: Center(
          child: widget.label == '⌫'
              ? Icon(
                  Icons.backspace_outlined,
                  size: 18,
                  color: widget.textColor,
                )
              : Text(
                  widget.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: widget.isSpecial ? 11 : 16,
                    fontWeight: FontWeight.w800,
                    color: widget.textColor,
                    letterSpacing: widget.isSpecial ? 0.5 : 0,
                  ),
                ),
        ),
      ),
    );
  }
}
