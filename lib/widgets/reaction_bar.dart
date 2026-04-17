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
    return Row(
      children: _emojis.entries.map((e) {
        final count = reactions[e.key] ?? 0;
        final isActive = myReaction == e.key;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onReact(e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withValues(alpha: 0.12) : AppColors.lightBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.value, style: const TextStyle(fontSize: 16)),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dark)),
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
