import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/empty_state.dart';

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

  void _showPostDialog() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    File? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Post Announcement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(hintText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'What\'s the announcement?'),
                ),
                const SizedBox(height: 12),
                if (selectedImage != null) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(selectedImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4, right: 4,
                        child: GestureDetector(
                          onTap: () => setSheetState(() => selectedImage = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image_outlined, color: AppColors.primary),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920, imageQuality: 80);
                        if (picked != null) {
                          setSheetState(() => selectedImage = File(picked.path));
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.camera, maxWidth: 1920, imageQuality: 80);
                        if (picked != null) {
                          setSheetState(() => selectedImage = File(picked.path));
                        }
                      },
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) return;
                        Navigator.pop(ctx);
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await context.read<AnnouncementProvider>().post(
                          title: titleCtrl.text.trim(),
                          body: bodyCtrl.text.trim(),
                          image: selectedImage,
                        );
                        messenger.showSnackBar(SnackBar(
                          content: Text(ok ? 'Announcement posted!' : 'Failed to post'),
                          backgroundColor: ok ? AppColors.success : AppColors.danger,
                        ));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      child: const Text('Post'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AnnouncementProvider>();
    final canPost = context.watch<AuthProvider>().user?.isManager ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      floatingActionButton: canPost
          ? FloatingActionButton(
              onPressed: _showPostDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.edit, color: Colors.white),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ap.fetchFeed(refresh: true),
        child: ap.announcements.isEmpty && !ap.loading
            ? EmptyState(icon: Icons.campaign_outlined, title: 'No announcements yet', subtitle: 'Pull down to refresh', onAction: () => ap.fetchFeed(refresh: true))
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
