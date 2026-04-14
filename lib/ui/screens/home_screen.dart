// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../features/game/game_provider.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import 'custom_mode_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final stats = provider.stats;

    return Scaffold(
      backgroundColor: context.isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, provider, stats.currentStreak),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildHero(context),
                    const SizedBox(height: 28),
                    _buildBentoGrid(context, provider),
                    const SizedBox(height: 24),
                    _buildQuickStats(context, stats),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomNav(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, GameProvider provider, int streak) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'Word Wipeout',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: context.primaryColor,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          _StreakPill(streak: streak),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: provider.toggleTheme,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: context.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                provider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: context.onSurfaceVariant,
                size: 18,
              ),
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
          'WELCOME BACK',
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
                text: 'Choose your\n',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: context.onSurface,
                  height: 1.15,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: 'experience',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: context.primaryContainer,
                  height: 1.15,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: context.primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(BuildContext context, GameProvider provider) {
    return Column(
      children: [
        // Classic Mode - full width hero card
        _ClassicModeCard(
          hasActiveGame: provider.hasActiveGame && provider.mode == GameMode.classic,
          onTap: () {
            // If a classic game is in progress, just resume it
            if (!provider.hasActiveGame || provider.mode != GameMode.classic) {
              provider.startClassicMode();
            }
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const GameScreen()));
          },
        ),
        const SizedBox(height: 14),
        // Custom + Rage side by side
        Row(
          children: [
            Expanded(
              child: _CustomModeCard(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const CustomModeScreen()));
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _RageModeCard(
                hasActiveGame: provider.hasActiveGame && provider.mode == GameMode.rage,
                onTap: () {
                  if (provider.hasActiveGame && provider.mode == GameMode.rage) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
                    return;
                  }
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (sheetContext) => _RageFlavorModal(provider: provider),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR STATS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: context.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _QuickStatTile(
              label: 'Played',
              value: '${stats.gamesPlayed}',
              context: context,
            ),
            const SizedBox(width: 10),
            _QuickStatTile(
              label: 'Win Rate',
              value: '${stats.winRate.toStringAsFixed(0)}%',
              accent: context.tertiary,
              context: context,
            ),
            const SizedBox(width: 10),
            _QuickStatTile(
              label: 'Best Streak',
              value: '${stats.bestStreak}',
              context: context,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, GameProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.darkBackground.withOpacity(0.9)
            : AppColors.lightBackground.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Play',
                isActive: true,
                context: context,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Stats',
                isActive: false,
                context: context,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StatsScreen())),
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isActive: false,
                context: context,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mode Cards ─────────────────────────────────────────────────

class _ClassicModeCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasActiveGame;

  const _ClassicModeCard({required this.onTap, this.hasActiveGame = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: context.primaryColor.withOpacity(0.06),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background glow
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primaryColor.withOpacity(0.07),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          hasActiveGame ? 'IN PROGRESS' : 'DAILY CHALLENGE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: context.primaryColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Level count logic can be updated via Consumer
                      Consumer<GameProvider>(
                        builder: (context, provider, _) {
                            int level = provider.stats.currentStreak;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.tertiary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'Lvl. $level',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: context.tertiary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            );
                        }
                      ),
                      const Spacer(),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.grid_view_rounded,
                            color: context.primaryColor, size: 26),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Classic Mode',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: context.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Guess the word with precise choices.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: context.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _PlayNowButton(
                        context: context,
                        label: hasActiveGame ? 'Continue' : 'Play Now',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomModeCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CustomModeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: context.outlineVariant.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? AppColors.darkSecondaryContainer.withOpacity(0.3)
                          : AppColors.lightSecondaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune_rounded,
                        color: context.isDark
                            ? AppColors.darkSecondary
                            : AppColors.lightSecondary,
                        size: 20),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Custom',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: context.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      'Your rules, your words.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: context.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  'Configure',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded,
                    size: 14, color: context.primaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RageModeCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasActiveGame;

  const _RageModeCard({required this.onTap, this.hasActiveGame = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.tertiary.withOpacity(0.05),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.tertiary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.bolt_rounded,
                      color: context.tertiary, size: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  'Rage Bait',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: context.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '3 lives. Increasing difficulty.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: context.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      hasActiveGame ? 'Continue Storm' : 'Enter the Storm',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.tertiary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.local_fire_department_rounded,
                        size: 14, color: context.tertiary),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Supporting Widgets ────────────────────────────────────────

class _PlayNowButton extends StatelessWidget {
  final BuildContext context;
  final String label;

  const _PlayNowButton({required this.context, this.label = 'Play Now'});

  @override
  Widget build(BuildContext outerContext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [outerContext.primaryColor, outerContext.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: outerContext.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: outerContext.isDark
              ? AppColors.darkOnPrimaryContainer
              : AppColors.lightOnPrimaryContainer,
        ),
      ),
    );
  }
}

class _QuickStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? accent;
  final BuildContext context;

  const _QuickStatTile({
    required this.label,
    required this.value,
    required this.context,
    this.accent,
  });

  @override
  Widget build(BuildContext outerContext) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: outerContext.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: accent != null
              ? Border(
                  left: BorderSide(color: accent!, width: 3),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: outerContext.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: accent ?? outerContext.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final BuildContext context;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.context,
    required this.onTap,
  });

  @override
  Widget build(BuildContext outerContext) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? outerContext.surfaceContainerHigh
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive
                  ? outerContext.primaryColor
                  : outerContext.onSurfaceVariant.withOpacity(0.4),
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? outerContext.primaryColor
                  : outerContext.onSurfaceVariant.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int streak;

  const _StreakPill({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$streak',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: context.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Text('🔥', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Rage Flavor Modal ───────────────────────────────────────────

class _RageFlavorModal extends StatefulWidget {
  final GameProvider provider;

  const _RageFlavorModal({required this.provider});

  @override
  State<_RageFlavorModal> createState() => _RageFlavorModalState();
}

class _RageFlavorModalState extends State<_RageFlavorModal> {
  double _difficultyIndex = 2.0;

  final List<Color> _colors = const [
    Color(0xFFF6D7C3), // 0: Very light
    Color(0xFFE8B89A), // 1: Light
    Color(0xFFC98A6B), // 2: Medium
    Color(0xFF8A5A3B), // 3: Dark
    Color(0xFF4A2C1A), // 4: Very dark
  ];

  final List<String> _labels = const [
    'Very light',
    'Light',
    'Medium',
    'Dark',
    'Very dark'
  ];

  @override
  Widget build(BuildContext context) {
    final int idx = _difficultyIndex.round();
    final Color activeColor = _colors[idx];
    final String activeLabel = _labels[idx];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CHOOSE YOUR SKIN TONE', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: activeColor, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text('Rage Bait Difficulty', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, color: context.onSurface, letterSpacing: -1)),
            const SizedBox(height: 6),
            Text('Slide to adjust your suffering level.', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: context.onSurfaceVariant)),
            const SizedBox(height: 32),
            
            // Slider display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(activeLabel, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: activeColor)),
                Icon(Icons.local_fire_department_rounded, color: activeColor, size: 28),
              ]
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: activeColor,
                inactiveTrackColor: activeColor.withOpacity(0.2),
                thumbColor: activeColor,
                trackHeight: 8.0,
              ),
              child: Slider(
                value: _difficultyIndex,
                min: 0,
                max: 4,
                divisions: 4,
                onChanged: (val) {
                  setState(() {
                    _difficultyIndex = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
            
            // Start Action
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.provider.startRageMode(difficulty: idx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                  ]
                ),
                child: Center(
                  child: Text(
                    'Begin Suffering',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
