// lib/ui/screens/custom_mode_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../features/game/game_provider.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class CustomModeScreen extends StatefulWidget {
  const CustomModeScreen({super.key});

  @override
  State<CustomModeScreen> createState() => _CustomModeScreenState();
}

class _CustomModeScreenState extends State<CustomModeScreen> {
  final _wordController = TextEditingController();
  final _focusNode = FocusNode();
  String? _errorText;

  @override
  void dispose() {
    _wordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addWord(GameProvider provider) {
    final word = _wordController.text.trim().toUpperCase();

    if (word.isEmpty) {
      setState(() => _errorText = 'Enter a word.');
      return;
    }
    if (word.length < 4 || word.length > 8) {
      setState(() => _errorText = 'Word must be 4–8 letters.');
      return;
    }
    if (!RegExp(r'^[A-Z]+$').hasMatch(word)) {
      setState(() => _errorText = 'Letters only, no spaces.');
      return;
    }

    provider.addCustomWord(word);
    _wordController.clear();
    setState(() => _errorText = null);
  }

  void _startGame(BuildContext context, GameProvider provider) {
    final words = provider.customWords;
    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add at least one word to start.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: context.surfaceContainerHigh,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Filter words by chosen length
    final matchingWords = words
        .where((w) => w.length == provider.customWordLength)
        .toList();

    if (matchingWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No ${provider.customWordLength}-letter words in your list.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: context.errorColor.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    provider.startCustomMode(pool: matchingWords);
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const GameScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: context.isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildHero(context),
                    const SizedBox(height: 28),
                    _buildWordInputSection(context, provider),
                    const SizedBox(height: 20),
                    _buildWordList(context, provider),
                    const SizedBox(height: 20),
                    _buildMechanicsSection(context, provider),
                    const SizedBox(height: 20),
                    _buildPreviewCard(context, provider),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildStartButton(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
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
          Text(
            'Configure Game',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            'Custom Mode',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CUSTOM MODE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: context.primaryColor,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Create your own\n',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: context.onSurface,
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: 'Challenge',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: context.primaryContainer,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWordInputSection(BuildContext context, GameProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: '01. ADD WORDS', context: context),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wordController,
                      focusNode: _focusNode,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a word (4–8 letters)...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          color: context.onSurfaceVariant.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _addWord(provider),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _addWord(provider),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_rounded,
                          color: context.onPrimaryContainer, size: 20),
                    ),
                  ),
                ],
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorText!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: context.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWordList(BuildContext context, GameProvider provider) {
    final words = provider.customWords;
    if (words.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${words.length} word${words.length != 1 ? 's' : ''} added',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => provider.clearCustomWords(),
              child: Text(
                'Clear all',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.errorColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: words.asMap().entries.map((e) {
            return _WordChip(
              word: e.value.text,
              onDelete: () => provider.deleteCustomWord(e.key),
              context: context,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMechanicsSection(BuildContext context, GameProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: '02. WORD LENGTH', context: context),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (i) {
            final len = i + 4;
            final isSelected = provider.customWordLength == len;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => provider.setCustomWordLength(len),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.surfaceContainerHighest
                        : context.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: context.primaryColor.withOpacity(0.5),
                            width: 1.5)
                        : Border.all(
                            color: context.outlineVariant.withOpacity(0.1)),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: context.primaryColor.withOpacity(0.15),
                              blurRadius: 12,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$len',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? context.primaryColor
                            : context.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        _SectionLabel(label: '03. ATTEMPTS', context: context),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: context.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Max Attempts',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.onSurface,
                    ),
                  ),
                  Text(
                    'How many tries per word',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: context.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (provider.customAttempts > 4)
                    provider.setCustomAttempts(provider.customAttempts - 1);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.remove_rounded,
                      size: 16, color: context.onSurface),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '${provider.customAttempts}'.padLeft(2, '0'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: context.primaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (provider.customAttempts < 10)
                    provider.setCustomAttempts(provider.customAttempts + 1);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add_rounded,
                      size: 16, color: context.onSurface),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard(BuildContext context, GameProvider provider) {
    final words = provider.customWords;
    final matching = words
        .where((w) => w.length == provider.customWordLength)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.outlineVariant.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: context.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.workspace_premium_rounded,
                color: context.tertiary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Game Preview",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: context.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.customWordLength}-letter words · ${provider.customAttempts} attempts · $matching available',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: context.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, GameProvider provider) {
    return Container(
      padding:
          EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        border: Border(
          top: BorderSide(color: context.outlineVariant.withOpacity(0.08)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
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
            onPressed: () => _startGame(context, provider),
            child: Text(
              'Start Custom Game',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.isDark
                    ? AppColors.darkOnPrimaryContainer
                    : AppColors.lightOnPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Supporting Widgets ────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final BuildContext context;

  const _SectionLabel({required this.label, required this.context});

  @override
  Widget build(BuildContext outerContext) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: outerContext.onSurfaceVariant,
        letterSpacing: 1.8,
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final VoidCallback onDelete;
  final BuildContext context;

  const _WordChip(
      {required this.word, required this.onDelete, required this.context});

  @override
  Widget build(BuildContext outerContext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: outerContext.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            word,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: outerContext.onSurface,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close_rounded,
                size: 14,
                color: outerContext.onSurfaceVariant.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
