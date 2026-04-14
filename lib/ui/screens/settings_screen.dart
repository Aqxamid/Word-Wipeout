// lib/ui/screens/settings_screen.dart
// Simplified: Gemini API key only + Local Ollama + Appearance
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/models/ai_model.dart';
import '../../features/game/game_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _geminiController = TextEditingController();
  bool _showKey = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadKeys());
  }

  void _loadKeys() {
    final p = context.read<GameProvider>();
    _geminiController.text = p.getApiKey('gemini');
  }

  @override
  void dispose() {
    _geminiController.dispose();
    super.dispose();
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  const SizedBox(height: 8),

                  // ── AI Features ───────────────────────────────────────
                  _buildSection(
                    context,
                    icon: Icons.auto_awesome_rounded,
                    title: 'AI Features',
                    child: Column(
                      children: [

                        _ToggleTile(
                          label: 'Post-Game Insights',
                          subtitle:
                              'Show AI definition & fun fact after each game',
                          value: provider.insightsEnabled,
                          onChanged: (v) => provider.setInsights(v),
                          context: context,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Gemini API Key ────────────────────────────────────
                  _buildSection(
                    context,
                    icon: Icons.vpn_key_rounded,
                    title: 'Google Gemini API Key',
                    subtitle: 'Get your free key at aistudio.google.com/app/apikey',
                    child: _GeminiKeyField(
                      controller: _geminiController,
                      showKey: _showKey,
                      onToggleShow: () =>
                          setState(() => _showKey = !_showKey),
                      onSave: (v) =>
                          context.read<GameProvider>().saveApiKey('gemini', v),
                      context: context,
                    ),
                  ),
                  const SizedBox(height: 20),



                  // ── Action Log ─────────────────────────────────────────
                  // ── Local AI (GGUF) ───────────────────────────────────
                  _buildSection(
                    context,
                    icon: Icons.folder_rounded,
                    title: 'Local AI (GGUF)',
                    subtitle: 'Select a `.gguf` model file on this device to run totally offline.',
                    child: _LocalGgufSection(provider: provider),
                  ),
                  const SizedBox(height: 20),

                  // ── Action Log ─────────────────────────────────────────
                  _buildSection(
                    context,
                    icon: Icons.bug_report_rounded,
                    title: 'AI Debug Logs',
                    subtitle: 'View raw API prompt and response payloads.',
                    child: _buildDebugLogger(context, provider),
                  ),
                  const SizedBox(height: 20),

                  // ── Appearance ────────────────────────────────────────
                  _buildSection(
                    context,
                    icon: Icons.palette_rounded,
                    title: 'Appearance',
                    child: _ToggleTile(
                      label: 'Dark Mode',
                      subtitle: 'Toggle light / dark theme',
                      value: provider.isDarkMode,
                      onChanged: (_) => provider.toggleTheme(),
                      context: context,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Cache info ────────────────────────────────────────
                  _buildCacheInfo(context, provider),
                  const SizedBox(height: 20),

                  // ── About ─────────────────────────────────────────────
                  _buildSection(
                    context,
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    child: Center(
                      child: Text(
                        'Made by Aquamid',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          const SizedBox(width: 14),
          Text(
            'Settings',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: context.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Generic section card ──────────────────────────────────────

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: context.primaryColor),
            const SizedBox(width: 6),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: context.primaryColor,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: context.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: child,
        ),
      ],
    );
  }

  // ── Cache info ────────────────────────────────────────────────

  Widget _buildCacheInfo(BuildContext context, GameProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.storage_rounded,
              size: 16, color: context.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${provider.cachedInsightCount} words cached offline',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.onSurface,
                  ),
                ),
                Text(
                  'AI insights stored permanently on-device',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: context.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await provider.clearInsightCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared')),
                );
              }
            },
            child: Text(
              'Clear',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: context.errorColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gemini key field ──────────────────────────────────────────────

class _GeminiKeyField extends StatelessWidget {
  final TextEditingController controller;
  final bool showKey;
  final VoidCallback onToggleShow;
  final void Function(String) onSave;
  final BuildContext context;

  const _GeminiKeyField({
    required this.controller,
    required this.showKey,
    required this.onToggleShow,
    required this.onSave,
    required this.context,
  });

  @override
  Widget build(BuildContext outerContext) {
    final hasKey = controller.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasKey
                    ? const Color(0xFF22C55E)
                    : outerContext.onSurfaceVariant.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              hasKey ? 'Key saved ✓' : 'No key set',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasKey
                    ? const Color(0xFF22C55E)
                    : outerContext.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'FREE TIER AVAILABLE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4285F4),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: !showKey,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: outerContext.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'AIza...',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: outerContext.onSurfaceVariant.withOpacity(0.4),
            ),
            filled: true,
            fillColor: outerContext.surfaceContainerHigh,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(
                showKey
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 18,
                color: outerContext.onSurfaceVariant,
              ),
              onPressed: onToggleShow,
            ),
          ),
          onSubmitted: onSave,
          onChanged: onSave,
        ),
        const SizedBox(height: 8),
        Text(
          'Visit aistudio.google.com/app/apikey to generate a free key.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: outerContext.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

// ── Debug Logger ─────────────────────────────────────────────────

Widget _buildDebugLogger(BuildContext outerContext, GameProvider provider) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: outerContext,
        builder: (context) {
          return AlertDialog(
            title: Text('AI Response Logs', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
               child: provider.aiLogs.isEmpty 
                 ? Text('No logs available.', style: GoogleFonts.plusJakartaSans())
                 : ListView.builder(
                    itemCount: provider.aiLogs.length,
                    itemBuilder: (context, i) {
                      final log = provider.aiLogs[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: context.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Prompt:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: context.primaryColor)),
                            Text(log['prompt'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 10)),
                            const SizedBox(height: 8),
                            Text('Response:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                            Text(log['response'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 10)),
                          ]
                        )
                      );
                    }
                 )
            ),
            actions: [
               TextButton(onPressed: () { provider.clearAiLogs(); Navigator.pop(context); }, child: const Text('Clear')),
               TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
            ],
          );
        }
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: outerContext.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outerContext.outlineVariant.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('View Debug Logs', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: outerContext.onSurface)),
          Icon(Icons.open_in_new_rounded, size: 16, color: outerContext.onSurfaceVariant)
        ]
      )
    )
  );
}

// ── Local GGUF Section ──────────────────────────────────────────

class _LocalGgufSection extends StatefulWidget {
  final GameProvider provider;
  const _LocalGgufSection({required this.provider});

  @override
  State<_LocalGgufSection> createState() => _LocalGgufSectionState();
}

class _LocalGgufSectionState extends State<_LocalGgufSection> {
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
      );
      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        
        bool isCachePath = path.contains('/cache/') || path.contains('/com.android.providers');
        final docDir = await getApplicationDocumentsDirectory();
        bool isAlreadyInDocs = path.contains(docDir.path);
        
        if (isCachePath && !isAlreadyInDocs) {
          final newPath = '${docDir.path}/model.gguf';
          if (path != newPath) {
             final newFile = File(newPath);
             if (await newFile.exists()) await newFile.delete();
             await File(path).copy(newPath);
             path = newPath;
          }
        }
        
        widget.provider.setGgufPath(path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to read file path. Please ensure the file is downloaded to your device storage.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _clearFile() {
    widget.provider.setGgufPath('');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasModel = widget.provider.ggufPath.isNotEmpty;
    final String modelName = hasModel ? widget.provider.ggufPath.split(RegExp(r'[\\/]')).last : 'No model loaded';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasModel ? const Color(0xFF22C55E).withOpacity(0.1) : context.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasModel ? const Color(0xFF22C55E) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(hasModel ? Icons.check_circle_rounded : Icons.cancel_presentation_rounded, size: 24, color: hasModel ? const Color(0xFF22C55E) : context.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(modelName, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: context.onSurface)),
                    if (hasModel) Text('Loaded globally', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: context.onSurfaceVariant))
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.file_upload_rounded, size: 16),
                label: const Text('Load File'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.onSurface,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (hasModel) const SizedBox(width: 8),
            if (hasModel)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearFile,
                  icon: const Icon(Icons.delete_rounded, size: 16),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        )
      ],
    );
  }
}


// ── Toggle Tile ──────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;
  final BuildContext context;

  const _ToggleTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.context,
  });

  @override
  Widget build(BuildContext outerContext) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: outerContext.onSurface)),
              Text(subtitle,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: outerContext.onSurfaceVariant)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: outerContext.primaryColor,
        ),
      ],
    );
  }
}
