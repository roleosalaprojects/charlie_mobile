import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';
import '../../widgets/announcement_card.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().fetchFeed(refresh: true);
    });
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 300) {
      context.read<AnnouncementProvider>().fetchFeed();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AnnouncementProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: RefreshIndicator(
        onRefresh: () => ap.fetchFeed(refresh: true),
        child: ap.announcements.isEmpty && !ap.loading
            ? const Center(child: Text('No announcements yet.', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(12),
                itemCount: ap.announcements.length + (ap.loading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i >= ap.announcements.length) {
                    return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                  }
                  return AnnouncementCard(
                    announcement: ap.announcements[i],
                    onReact: (id, type) => ap.react(id, type),
                    onComment: (id, body, {int? parentId}) => ap.comment(id, body, parentId: parentId),
                  );
                },
              ),
      ),
    );
  }
}
