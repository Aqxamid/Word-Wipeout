// lib/ui/widgets/ai_insight_panel.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/ai_insight.dart';
import '../../core/models/ai_model.dart';
import '../theme/app_theme.dart';

/// Displays the AI insight card inside the result modal.
/// Shows a shimmer skeleton while loading, hides gracefully if null.
class AiInsightPanel extends StatefulWidget {
  final AiInsight? insight;
  final bool isLoading;

  const AiInsightPanel({
    super.key,
    required this.insight,
    required this.isLoading,
  });

  @override
  State<AiInsightPanel> createState() => _AiInsightPanelState();
}

class _AiInsightPanelState extends State<AiInsightPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.insight == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Divider(context: context),
        const SizedBox(height: 16),
        _header(context),
        const SizedBox(height: 12),
        widget.isLoading ? _skeleton(context) : _content(context),
      ],
    );
  }

  Widget _header(BuildContext context) {
    final model = widget.insight != null
        ? AiModels.findById(widget.insight!.modelId)
        : null;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: (model?.color ?? context.primaryColor).withOpacity(0.12),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 10,
                color: model?.color ?? context.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                widget.isLoading
                    ? 'AI ANALYZING…'
                    : 'AI INSIGHT · ${widget.insight!.modelDisplayName.toUpperCase()}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: model?.color ?? context.primaryColor,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        if (!widget.isLoading && widget.insight != null) ...[
          const Spacer(),
          Text(
            _timeAgo(widget.insight!.cachedAt),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              color: context.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _content(BuildContext context) {
    final insight = widget.insight!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          icon: Icons.menu_book_rounded,
          label: 'DEFINITION',
          text: insight.definition,
          context: context,
        ),
        const SizedBox(height: 10),
        _InfoRow(
          icon: Icons.lightbulb_outline_rounded,
          label: 'FUN FACT',
          text: insight.fact,
          context: context,
        ),
      ],
    );
  }

  Widget _skeleton(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        final shimmerColor = context.isDark
            ? Color.lerp(
                AppColors.darkSurfaceContainerHigh,
                AppColors.darkSurfaceBright,
                _shimmer.value,
              )!
            : Color.lerp(
                AppColors.lightSurfaceContainerHigh,
                AppColors.lightSurfaceContainer,
                _shimmer.value,
              )!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: double.infinity, height: 14, color: shimmerColor),
            const SizedBox(height: 6),
            _ShimmerBox(width: 200, height: 14, color: shimmerColor),
            const SizedBox(height: 14),
            _ShimmerBox(width: double.infinity, height: 14, color: shimmerColor),
            const SizedBox(height: 6),
            _ShimmerBox(width: 160, height: 14, color: shimmerColor),
          ],
        );
      },
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _Divider extends StatelessWidget {
  final BuildContext context;
  const _Divider({required this.context});

  @override
  Widget build(BuildContext outerContext) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: outerContext.outlineVariant.withOpacity(0.15),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 12,
            color: outerContext.onSurfaceVariant.withOpacity(0.3),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: outerContext.outlineVariant.withOpacity(0.15),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final BuildContext context;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.text,
    required this.context,
  });

  @override
  Widget build(BuildContext outerContext) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: outerContext.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: outerContext.onSurfaceVariant),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: outerContext.onSurfaceVariant.withOpacity(0.6),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: outerContext.onSurface,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
