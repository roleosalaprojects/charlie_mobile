import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class ReactionBar extends StatelessWidget {
  final Map<String, int> reactions;
  final String? myReaction;
  final Function(String type) onReact;

  const ReactionBar({
    super.key,
    required this.reactions,
    this.myReaction,
    required this.onReact,
  });

  static const _emojis = {
    'like': '👍',
    'love': '❤️',
    'celebrate': '🎉',
    'support': '👏',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.lightBg;
    final chipActiveBg = AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.1);
    final countColor = isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.dark;

    return Row(
      children: _emojis.entries.map((e) {
        final count = reactions[e.key] ?? 0;
        final isActive = myReaction == e.key;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onReact(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? chipActiveBg : chipBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isActive ? AppColors.primary.withValues(alpha: 0.35) : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.value, style: const TextStyle(fontSize: 16)),
                  if (count > 0) ...[
                    const SizedBox(width: 5),
                    Text('$count',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isActive ? AppColors.primary : countColor,
                        )),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
