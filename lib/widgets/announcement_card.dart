import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/announcement.dart';
import '../utils/helpers.dart';
import 'image_viewer.dart';
import 'reaction_bar.dart';
import 'comment_section.dart';

class AnnouncementCard extends StatefulWidget {
  final Announcement announcement;
  final Function(int id, String type) onReact;
  final Function(int id, String body, {int? parentId}) onComment;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onReact,
    required this.onComment,
  });

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard> {
  bool _showComments = false;

  Announcement get a => widget.announcement;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.isPinned)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.push_pin_rounded, size: 12, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Pinned', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),

            // Author
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: a.author.photoUrl != null ? CachedNetworkImageProvider(a.author.photoUrl!) : null,
                  child: a.author.photoUrl == null ? const Icon(Icons.person, size: 20, color: AppColors.primary) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.author.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(a.timeAgo, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Text(a.title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2, height: 1.3)),
            const SizedBox(height: 6),
            Text(a.body, style: const TextStyle(fontSize: 14, color: AppColors.muted, height: 1.55)),

            if (a.imageUrl != null && a.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  ImageViewer.route(a.imageUrl!, 'announcement-image-${a.id}'),
                ),
                child: Hero(
                  tag: 'announcement-image-${a.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      imageUrl: a.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(height: 200, color: AppColors.lightBg),
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ],

            if (a.totalReactions > 0 || a.commentsCount > 0) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (a.totalReactions > 0)
                    Text('${a.totalReactions} reaction${a.totalReactions > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  if (a.commentsCount > 0)
                    GestureDetector(
                      onTap: () => setState(() => _showComments = !_showComments),
                      child: Text('${a.commentsCount} comment${a.commentsCount > 1 ? 's' : ''}',
                          style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Divider(height: 1, color: Colors.grey[200]),
            const SizedBox(height: 12),

            ReactionBar(
              reactions: a.reactions,
              myReaction: a.myReaction,
              onReact: (type) => widget.onReact(a.id, type),
            ),

            if (_showComments || a.comments.isNotEmpty) ...[
              const SizedBox(height: 14),
              CommentSection(
                comments: a.comments,
                announcementId: a.id,
                onComment: widget.onComment,
              ),
            ] else ...[
              const SizedBox(height: 10),
              CommentSection(
                comments: const [],
                announcementId: a.id,
                onComment: widget.onComment,
                inputOnly: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
