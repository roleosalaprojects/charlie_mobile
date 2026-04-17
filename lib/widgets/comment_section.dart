import 'package:flutter/material.dart';
import '../models/announcement.dart';

class CommentSection extends StatefulWidget {
  final List<AnnouncementComment> comments;
  final int announcementId;
  final Function(int id, String body, {int? parentId}) onComment;
  final bool inputOnly;

  const CommentSection({
    super.key,
    required this.comments,
    required this.announcementId,
    required this.onComment,
    this.inputOnly = false,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _ctrl = TextEditingController();
  int? _replyTo;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onComment(widget.announcementId, text, parentId: _replyTo);
    _ctrl.clear();
    setState(() => _replyTo = null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.inputOnly)
          ...widget.comments.map((c) => _buildComment(c)),

        // Input
        if (_replyTo != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text('Replying...', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                GestureDetector(
                  onTap: () => setState(() => _replyTo = null),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.close, size: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: _replyTo != null ? 'Write a reply...' : 'Write a comment...',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, size: 20),
              onPressed: _submit,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComment(AnnouncementComment c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(text: c.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const TextSpan(text: '  '),
                          TextSpan(text: c.body, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(c.timeAgo, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => setState(() => _replyTo = c.id),
                          child: Text('Reply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Replies
          ...c.replies.map((r) => Padding(
                padding: const EdgeInsets.only(left: 36, top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(text: r.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                            const TextSpan(text: '  '),
                            TextSpan(text: r.body, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
