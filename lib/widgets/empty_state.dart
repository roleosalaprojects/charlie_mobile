import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;
  final String? emoji;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionLabel,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.accent.withValues(alpha: 0.12),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: emoji != null
                    ? Text(emoji!, style: const TextStyle(fontSize: 36))
                    : Icon(icon, size: 36, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5),
                  textAlign: TextAlign.center),
            ],
            if (onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(actionLabel ?? 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const ErrorState({super.key, this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '😕',
      icon: Icons.wifi_off_rounded,
      title: message ?? 'Something went wrong',
      subtitle: 'Check your connection and try again.',
      onAction: onRetry,
      actionLabel: 'Retry',
    );
  }
}
