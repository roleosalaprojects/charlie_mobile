import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/helpers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionLabel('Appearance'),
          _AppearanceCard(),
          SizedBox(height: 24),
          _SectionLabel('About'),
          _AboutCard(),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.3)),
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dark_mode_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theme', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('Choose how Charlie looks on your device',
                        style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ThemeSegment(
            value: theme.mode,
            onChanged: (m) => context.read<ThemeProvider>().setMode(m),
          ),
        ],
      ),
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;
  const _ThemeSegment({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackBg = isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.lightBg;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: trackBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _segment(context, ThemeMode.system, Icons.brightness_auto_outlined, 'System'),
          _segment(context, ThemeMode.light, Icons.light_mode_outlined, 'Light'),
          _segment(context, ThemeMode.dark, Icons.dark_mode_outlined, 'Dark'),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, ThemeMode mode, IconData icon, String label) {
    final selected = value == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(mode),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected ? AppColors.softShadow : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? AppColors.primary : AppColors.muted),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.primary : AppColors.muted,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.dns_outlined, color: AppColors.muted),
            title: const Text('Server Settings'),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            onTap: () => Navigator.pushNamed(context, '/server-config'),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.3), indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: AppColors.muted),
            title: const Text('About Charlie HRMS'),
            subtitle: const Text('v1.0.0', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Charlie HRMS',
              applicationVersion: '1.0.0',
              applicationLegalese: 'All rights reserved.',
              children: const [
                SizedBox(height: 16),
                Text(
                  'A Philippine-localized Human Resource Management System for attendance tracking, leave management, and employee self-service.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
