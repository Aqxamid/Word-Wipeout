// lib/ui/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/player_stats_model.dart';
import '../../features/game/game_provider.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

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
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildOverviewGrid(context, stats),
                    const SizedBox(height: 20),
                    _buildStreakSection(context, stats),
                    const SizedBox(height: 20),
                    _buildGuessDistribution(context, stats),
                    const SizedBox(height: 20),
                    Text(
            'Achievements',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildAchievementList(context, stats),
          const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
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
            'Your Stats',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: context.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Text(
            'Word Wipeout',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid(BuildContext context, PlayerStatsModel stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          label: 'Played',
          value: '${stats.gamesPlayed}',
          context: context,
        ),
        _StatCard(
          label: 'Win Rate',
          value: '${stats.winRate.toStringAsFixed(0)}%',
          accentLeft: context.tertiary,
          context: context,
        ),
        _StatCard(
          label: 'Current Streak',
          value: '${stats.currentStreak} 🔥',
          context: context,
        ),
        _StatCard(
          label: 'Best Streak',
          value: '${stats.bestStreak}',
          context: context,
        ),
      ],
    );
  }

  Widget _buildStreakSection(BuildContext context, PlayerStatsModel stats) {
    final maxStreak = stats.bestStreak == 0 ? 1 : stats.bestStreak;
    final currentPct = stats.currentStreak / maxStreak;
    final avgGuesses = _calcAvgGuesses(stats);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STREAK HISTORY',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: context.onSurfaceVariant,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _StreakBar(
                  label: 'Current',
                  value: stats.currentStreak,
                  maxValue: maxStreak,
                  color: context.surfaceContainerHighest,
                  context: context,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StreakBar(
                  label: 'Best',
                  value: stats.bestStreak,
                  maxValue: maxStreak,
                  color: context.primaryContainer,
                  isHighlight: true,
                  context: context,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StreakBar(
                  label: 'Avg',
                  value: avgGuesses,
                  maxValue: 8,
                  color: context.surfaceContainerHighest,
                  isDecimal: true,
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuessDistribution(
      BuildContext context, PlayerStatsModel stats) {
    final maxCount = stats.guessDistribution.values
        .fold<int>(0, (p, e) => e > p ? e : p);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Guess Distribution',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Icon(Icons.bar_chart_rounded,
                  color: context.onSurfaceVariant, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(8, (i) {
            final guess = i + 1;
            final count = stats.guessDistribution[guess] ?? 0;
            final pct = maxCount == 0 ? 0.0 : count / maxCount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    child: Text(
                      '$guess',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: context.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final barWidth =
                            (pct * constraints.maxWidth).clamp(28.0, constraints.maxWidth);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: 30,
                          width: barWidth,
                          decoration: BoxDecoration(
                            color: pct > 0
                                ? context.primaryContainer
                                : context.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: pct > 0.5
                                ? [
                                    BoxShadow(
                                      color: context.primaryContainer
                                          .withOpacity(0.2),
                                      blurRadius: 10,
                                    )
                                  ]
                                : null,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '$count',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: pct > 0
                                      ? context.onPrimaryContainer
                                      : context.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _buildAchievementList(BuildContext context, PlayerStatsModel stats) {
    const list = <Widget>[];
    
    // Helper closure
    Widget buildCard(String t, String s, int target, int cur, Color c) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildAchievementCard(
          context,
          title: t,
          subtitle: s,
          target: target,
          current: cur,
          iconColor: c,
        ),
      );
    }

    final ones = stats.guessDistribution[1] ?? 0;
    final twos = stats.guessDistribution[2] ?? 0;
    final closeCalls = (stats.guessDistribution[6] ?? 0) + (stats.guessDistribution[7] ?? 0) + (stats.guessDistribution[8] ?? 0);

    return [
      buildCard('First Step', 'Solve 1 puzzle', 1, stats.gamesWon, Colors.lightBlue),
      buildCard('Novice', 'Solve 10 puzzles', 10, stats.gamesWon, Colors.blue),
      buildCard('Adept', 'Solve 50 puzzles', 50, stats.gamesWon, Colors.blueAccent),
      buildCard('Veteran', 'Solve 100 puzzles', 100, stats.gamesWon, Colors.indigoAccent),
      buildCard('Master', 'Solve 250 puzzles', 250, stats.gamesWon, Colors.deepPurpleAccent),
      buildCard('Grand Curator', 'Solve 500 puzzles', 500, stats.gamesWon, context.tertiary),
      buildCard('Legend', 'Solve 1000 puzzles', 1000, stats.gamesWon, Colors.amber),
      buildCard('Warmup', 'Play 5 games', 5, stats.gamesPlayed, Colors.teal),
      buildCard('Consistent', 'Play 20 games', 20, stats.gamesPlayed, Colors.teal),
      buildCard('Dedicated', 'Play 100 games', 100, stats.gamesPlayed, Colors.teal),
      buildCard('Addict', 'Play 1000 games', 1000, stats.gamesPlayed, Colors.teal),
      buildCard('Hot Streak', 'Reach a 3 win streak', 3, stats.bestStreak, Colors.orangeAccent),
      buildCard('On Fire', 'Reach a 10 win streak', 10, stats.bestStreak, Colors.deepOrangeAccent),
      buildCard('Unstoppable', 'Reach a 25 win streak', 25, stats.bestStreak, Colors.redAccent),
      buildCard('Flawless', 'Reach a 50 win streak', 50, stats.bestStreak, Colors.red),
      buildCard('Godlike', 'Reach a 100 win streak', 100, stats.bestStreak, Colors.purpleAccent),
      buildCard('First Blood', 'Play 1 Rage game', 1, stats.totalRageRuns, Colors.redAccent),
      buildCard('Survivor', 'Play 5 Rage games', 5, stats.totalRageRuns, Colors.redAccent),
      buildCard('Rage Baiter', 'Play 20 Rage games', 20, stats.totalRageRuns, Colors.redAccent),
      buildCard('Masochist', 'Play 50 Rage games', 50, stats.totalRageRuns, Colors.redAccent),
      buildCard('Clairvoyant', 'Guess the word on the 1st try', 1, ones, Colors.amberAccent),
      buildCard('Lucky', 'Guess the word on the 1st try 5 times', 5, ones, Colors.amberAccent),
      buildCard('Sniper', 'Guess the word on the 2nd try 10 times', 10, twos, Colors.green),
      buildCard('Close Call', 'Solve on the final attempts 10 times', 10, closeCalls, Colors.deepOrange),
    ];
  }

  Widget _buildAchievementCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int target,
    required int current,
    required Color iconColor,
  }) {
    final progress = (current / target).clamp(0.0, 1.0);
    final isDone = progress == 1.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone ? iconColor.withOpacity(0.3) : context.outlineVariant.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDone ? iconColor.withOpacity(0.15) : context.onSurface.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.workspace_premium_rounded : Icons.military_tech_rounded,
              color: isDone ? iconColor : context.onSurface.withOpacity(0.3),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDone ? context.onSurface : context.onSurfaceVariant,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: context.onSurfaceVariant.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: context.surfaceContainerLowest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? iconColor : context.primaryColor.withOpacity(0.5),
                    ),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDone ? 'Completed' : '$current / $target',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDone ? iconColor : context.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calcAvgGuesses(PlayerStatsModel stats) {
    if (stats.gamesWon == 0) return 0;
    int total = 0;
    int count = 0;
    stats.guessDistribution.forEach((k, v) {
      total += k * v;
      count += v;
    });
    return count == 0 ? 0 : total / count;
  }
}

// ── Supporting Widgets ────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? accentLeft;
  final BuildContext context;

  const _StatCard({
    required this.label,
    required this.value,
    required this.context,
    this.accentLeft,
  });

  @override
  Widget build(BuildContext outerContext) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: outerContext.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: accentLeft != null
            ? Border(left: BorderSide(color: accentLeft!, width: 3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: outerContext.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: outerContext.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBar extends StatelessWidget {
  final String label;
  final num value;
  final int maxValue;
  final Color color;
  final bool isHighlight;
  final bool isDecimal;
  final BuildContext context;

  const _StreakBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.context,
    this.isHighlight = false,
    this.isDecimal = false,
  });

  @override
  Widget build(BuildContext outerContext) {
    final pct = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    final displayValue = isDecimal
        ? value.toStringAsFixed(1)
        : '${value.toInt()}';

    return Column(
      children: [
        Text(
          displayValue,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: outerContext.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 80,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: double.infinity,
              height: (pct * 80).clamp(8, 80),
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
                boxShadow: isHighlight
                    ? [
                        BoxShadow(
                          color: outerContext.primaryContainer.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        )
                      ]
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: outerContext.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
