class Announcement {
  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final bool isPinned;
  final String publishedAt;
  final String timeAgo;
  final AnnouncementAuthor author;
  final Map<String, int> reactions;
  final String? myReaction;
  final int commentsCount;
  final List<AnnouncementComment> comments;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.isPinned,
    required this.publishedAt,
    required this.timeAgo,
    required this.author,
    required this.reactions,
    this.myReaction,
    required this.commentsCount,
    required this.comments,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    final reactionsMap = <String, int>{};
    if (json['reactions'] is Map) {
      (json['reactions'] as Map).forEach((k, v) {
        reactionsMap[k.toString()] = v is int ? v : 0;
      });
    }

    return Announcement(
      id: json['id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['image_url'],
      isPinned: json['is_pinned'] ?? false,
      publishedAt: json['published_at'] ?? '',
      timeAgo: json['time_ago'] ?? '',
      author: AnnouncementAuthor.fromJson(json['author'] ?? {}),
      reactions: reactionsMap,
      myReaction: json['my_reaction'],
      commentsCount: json['comments_count'] ?? 0,
      comments: (json['comments'] as List?)
              ?.map((c) => AnnouncementComment.fromJson(c))
              .toList() ??
          [],
    );
  }

  int get totalReactions => reactions.values.fold(0, (a, b) => a + b);
}

class AnnouncementAuthor {
  final String name;
  final String? photoUrl;

  AnnouncementAuthor({required this.name, this.photoUrl});

  factory AnnouncementAuthor.fromJson(Map<String, dynamic> json) {
    return AnnouncementAuthor(
      name: json['name'] ?? '',
      photoUrl: json['photo_url'],
    );
  }
}

class AnnouncementComment {
  final int id;
  final String body;
  final String timeAgo;
  final Map<String, dynamic> user;
  final List<AnnouncementComment> replies;

  AnnouncementComment({
    required this.id,
    required this.body,
    required this.timeAgo,
    required this.user,
    required this.replies,
  });

  String get userName => user['name'] ?? '';

  factory AnnouncementComment.fromJson(Map<String, dynamic> json) {
    return AnnouncementComment(
      id: json['id'],
      body: json['body'] ?? '',
      timeAgo: json['time_ago'] ?? '',
      user: json['user'] ?? {},
      replies: (json['replies'] as List?)
              ?.map((r) => AnnouncementComment.fromJson(r))
              .toList() ??
          [],
    );
  }
}
