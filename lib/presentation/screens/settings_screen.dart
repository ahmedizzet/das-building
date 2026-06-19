import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/member_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final user = memberProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.headlineMd),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(user),
            const SizedBox(height: 24),
            _buildSectionHeader("Account & Preferences"),
            _buildSettingsCard([
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: "Notifications",
                trailing: Switch.adaptive(
                  value: _notificationsEnabled,
                  activeColor: AppColors.secondary,
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                ),
              ),
              _buildSettingItem(
                icon: Icons.dark_mode_outlined,
                title: "Dark Mode",
                trailing: Switch.adaptive(
                  value: _darkMode,
                  activeColor: AppColors.secondary,
                  onChanged: (val) => setState(() => _darkMode = val),
                ),
              ),
              _buildSettingItem(
                icon: Icons.language_outlined,
                title: "Language",
                subtitle: "English (US)",
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),
            if (memberProvider.isAdmin) ...[
              _buildSectionHeader("Building Management"),
              _buildSettingsCard([
                _buildSettingItem(
                  icon: Icons.people_outline_rounded,
                  title: "Manage Members",
                  subtitle: "${memberProvider.allMembers.length} residents registered",
                  onTap: () {
                    // Navigate to a dedicated member management screen if needed
                    // For now, we keep it simple
                  },
                ),
                _buildSettingItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Financial Settings",
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 24),
            ],
            _buildSectionHeader("Support & About"),
            _buildSettingsCard([
              _buildSettingItem(
                icon: Icons.help_outline_rounded,
                title: "Help Center",
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Policy",
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.description_outlined,
                title: "Terms of Service",
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.info_outline_rounded,
                title: "App Version",
                subtitle: "1.0.0 (Build 42)",
              ),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showLogoutDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Log Out"),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.surfaceContainer,
            backgroundImage: user?.imageUrl != null ? NetworkImage(user.imageUrl) : null,
            child: user?.imageUrl == null
                ? const Icon(Icons.person, size: 32, color: AppColors.outline)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? "Resident",
                  style: AppTypography.headlineMd,
                ),
                Text(
                  user?.unit ?? "No unit assigned",
                  style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelBold.copyWith(
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          bool isLast = idx == children.length - 1;
          return Column(
            children: [
              child,
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 56,
                  endIndent: 16,
                  color: AppColors.outlineVariant,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.onSurfaceVariant),
      title: Text(title, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: AppTypography.bodySm) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, color: AppColors.outline) : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out of Civic Hearth?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Log Out", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
