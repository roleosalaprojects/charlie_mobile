import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dtr_provider.dart';
import '../../providers/leave_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_strip.dart';

/// Home tab — greeting, at-a-glance status strip, then announcements feed.
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
    _scrollCtrl.addListener(_onScroll);
  }

  Future<void> _loadAll() async {
    final ap = context.read<AnnouncementProvider>();
    final dtr = context.read<DtrProvider>();
    final leave = context.read<LeaveProvider>();
    final notif = context.read<NotificationProvider>();
    await Future.wait([
      ap.fetchFeed(refresh: true),
      dtr.fetchToday(),
      leave.fetchBalances(),
      notif.fetchUnreadCount(),
    ]);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 300) {
      context.read<AnnouncementProvider>().fetchFeed();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
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
                TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'Title')),
                const SizedBox(height: 12),
                TextField(controller: bodyCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'What\'s the announcement?')),
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
                        if (picked != null) setSheetState(() => selectedImage = File(picked.path));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.camera, maxWidth: 1920, imageQuality: 80);
                        if (picked != null) setSheetState(() => selectedImage = File(picked.path));
                      },
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) return;
                        Navigator.pop(ctx);
                        final ok = await context.read<AnnouncementProvider>().post(
                          title: titleCtrl.text.trim(),
                          body: bodyCtrl.text.trim(),
                          image: selectedImage,
                        );
                        if (!mounted) return;
                        if (ok) {
                          AppToast.success(context, 'Announcement posted');
                        } else {
                          AppToast.error(context, 'Failed to post');
                        }
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
    final auth = context.watch<AuthProvider>();
    final notif = context.watch<NotificationProvider>();
    final canPost = auth.user?.isManager ?? false;
    final emp = auth.user?.employee;
    final firstName = (emp?.fullName ?? auth.user?.name ?? '').split(' ').first;

    return Scaffold(
      floatingActionButton: canPost
          ? FloatingActionButton(
              heroTag: 'fab-post-announcement',
              onPressed: _showPostDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.edit, color: Colors.white),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            // Greeting header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 20, right: 16, bottom: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      backgroundImage: (emp?.photoUrl?.isNotEmpty ?? false) ? NetworkImage(emp!.photoUrl!) : null,
                      child: (emp?.photoUrl?.isEmpty ?? true) ? const Icon(Icons.person, size: 22, color: AppColors.primary) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_greeting(), style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(firstName.isEmpty ? 'Welcome' : firstName,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.1)),
                        ],
                      ),
                    ),
                    _NotifBell(
                      count: notif.unreadCount,
                      onTap: () => Navigator.pushNamed(context, '/notifications'),
                    ),
                  ],
                ),
              ),
            ),

            // Status strip
            const SliverToBoxAdapter(child: StatusStrip()),

            // Feed header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Announcements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    if (ap.announcements.isNotEmpty)
                      Text('${ap.announcements.length} posts', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
            ),

            // Feed
            if (ap.announcements.isEmpty && !ap.loading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  emoji: '🌴',
                  icon: Icons.campaign_outlined,
                  title: 'All quiet for now',
                  subtitle: 'No new announcements. Pull down to refresh.',
                  onAction: () => context.read<AnnouncementProvider>().fetchFeed(refresh: true),
                  actionLabel: 'Refresh',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList.builder(
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

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

class _NotifBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _NotifBell({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: onTap,
          color: Colors.grey[700],
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 9 ? '9+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}
