import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/announcement.dart';
import '../utils/helpers.dart';
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pin badge
            if (a.isPinned)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.push_pin, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text('Pinned', style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

            // Author
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: a.author.photoUrl != null ? CachedNetworkImageProvider(a.author.photoUrl!) : null,
                  child: a.author.photoUrl == null ? const Icon(Icons.person, size: 20) : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.author.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(a.timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title + Body
            Text(a.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(a.body, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4)),

            // Image
            if (a.imageUrl != null && a.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: a.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(height: 200, color: Colors.grey[200]),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],

            // Stats
            if (a.totalReactions > 0 || a.commentsCount > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (a.totalReactions > 0)
                    Text('${a.totalReactions} reaction${a.totalReactions > 1 ? 's' : ''}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  if (a.commentsCount > 0)
                    GestureDetector(
                      onTap: () => setState(() => _showComments = !_showComments),
                      child: Text('${a.commentsCount} comment${a.commentsCount > 1 ? 's' : ''}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ),
                ],
              ),
            ],
            const Divider(height: 24),

            // Reactions
            ReactionBar(
              reactions: a.reactions,
              myReaction: a.myReaction,
              onReact: (type) => widget.onReact(a.id, type),
            ),

            // Comments
            if (_showComments || a.comments.isNotEmpty) ...[
              const SizedBox(height: 12),
              CommentSection(
                comments: a.comments,
                announcementId: a.id,
                onComment: widget.onComment,
              ),
            ] else ...[
              const SizedBox(height: 8),
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
