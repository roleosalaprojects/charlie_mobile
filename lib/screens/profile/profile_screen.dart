import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final emp = auth.user?.employee;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Photo + name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: emp?.photoUrl != null ? NetworkImage(emp!.photoUrl!) : null,
                  child: emp?.photoUrl == null ? const Icon(Icons.person, size: 50) : null,
                ),
                const SizedBox(height: 12),
                Text(emp?.fullName ?? auth.user?.name ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(emp?.employeeNo ?? '', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Info cards
          _infoCard('Position', emp?.position ?? '--'),
          _infoCard('Department', emp?.department ?? '--'),
          _infoCard('Branch', emp?.branch ?? '--'),
          _infoCard('Email', auth.user?.email ?? '--'),

          const SizedBox(height: 24),

          // Change Password
          ListTile(
            leading: const Icon(Icons.lock_outline, color: AppColors.primary),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            tileColor: Colors.grey[50],
            onTap: () => Navigator.pushNamed(context, '/change-password'),
          ),
          const SizedBox(height: 12),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text('Logout', style: TextStyle(color: AppColors.danger)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            tileColor: AppColors.danger.withValues(alpha: 0.05),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout', style: TextStyle(color: AppColors.danger))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await auth.logout();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
