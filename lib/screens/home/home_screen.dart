import 'package:flutter/material.dart';
import '../../utils/helpers.dart';
import '../../widgets/status_strip.dart';
import '../announcements/announcements_screen.dart';
import '../dtr/dtr_screen.dart';
import '../leave/leave_screen.dart';
import '../more/more_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    AnnouncementsScreen(),
    DtrScreen(),
    LeaveScreen(),
    MoreScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    HomeScreenNavigator.register((index) {
      if (mounted) setState(() => _currentIndex = index);
    });
  }

  @override
  void dispose() {
    HomeScreenNavigator.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
                _navItem(1, Icons.access_time_outlined, Icons.access_time_filled, 'DTR'),
                _navItem(2, Icons.event_note_outlined, Icons.event_note_rounded, 'Leave'),
                _navItem(3, Icons.grid_view_outlined, Icons.grid_view_rounded, 'More'),
                _navItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, size: 22, color: isActive ? AppColors.primary : Colors.grey[400]),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ],
        ),
      ),
    );
  }
}
