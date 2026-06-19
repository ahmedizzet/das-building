import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/dashboard_provider.dart';
import '../providers/group_provider.dart';
import '../providers/sync_provider.dart';
import '../widgets/modern_components.dart';
import 'personal_screen.dart';
import 'chat_screen.dart';
import 'tickets_screen.dart';
import 'onboarding.dart';
import 'dashboard.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final String phoneNumber;
  const MainScreen({super.key, required this.phoneNumber});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _initialized = false;

  List<Widget> _getScreens(bool isAdmin) {
    return [
      const PersonalScreen(),
      const DashboardScreen(),
      const ChatScreen(),
      const TicketsScreen(),
      if (isAdmin) const OnboardingScreen(),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await context.read<DashboardProvider>().loadCurrentUser(widget.phoneNumber);
        if (mounted) {
          await context.read<GroupProvider>().loadGroup();
          if (mounted) {
            context.read<SyncProvider>().syncNow();
          }
        }
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _showProfile() {
    final user = context.read<DashboardProvider>().currentUser;
    ModernDialog.show(
      context,
      title: "My Profile",
      icon: Icons.person_rounded,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.surfaceContainer,
              backgroundImage: user?.imageUrl != null && user!.imageUrl.isNotEmpty
                  ? (user.imageUrl.startsWith('/') || user.imageUrl.startsWith('file://')
                      ? FileImage(File(user.imageUrl))
                      : NetworkImage(user.imageUrl))
                  : null,
              child: user?.imageUrl == null || user!.imageUrl.isEmpty
                  ? Icon(Icons.person, size: 40, color: AppColors.outline)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          _profileRow("Name", user?.name ?? 'Resident'),
          const SizedBox(height: 8),
          if (user?.unit != null && user!.unit.isNotEmpty)
            _profileRow("Unit", user.unit),
          if (user?.unit != null || user != null) const SizedBox(height: 8),
          _profileRow("Phone", user?.phoneNumber ?? widget.phoneNumber),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
          child: const Text("Close"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _openSettings();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Edit"),
        ),
      ],
    );
  }

  Widget _profileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
        Text(value, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = context.watch<GroupProvider>().currentGroup;
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Consumer<DashboardProvider>(
            builder: (context, dp, _) {
              final url = dp.currentUser?.imageUrl;
              return GestureDetector(
                onTap: _showProfile,
                child: CircleAvatar(
                  backgroundColor: AppColors.surfaceDim,
                  backgroundImage: url != null && url.isNotEmpty
                      ? (url.startsWith('/') || url.startsWith('file://')
                          ? FileImage(File(url))
                          : NetworkImage(url))
                      : null,
                  child: url == null || url.isEmpty
                      ? const Icon(Icons.person, color: AppColors.onSurface)
                      : null,
                ),
              );
            },
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<DashboardProvider>(
              builder: (context, dp, _) => Text(
                dp.currentUser?.name ?? 'DAS User',
                style: AppTypography.headlineMd,
              ),
            ),
            if (group != null)
              Text(group.name, style: AppTypography.bodySm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          Consumer<SyncProvider>(
            builder: (context, syncProvider, child) {
              return IconButton(
                onPressed: syncProvider.isSyncing ? null : () => syncProvider.syncNow(),
                icon: syncProvider.isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (syncProvider.serverReachable ? AppColors.secondary : AppColors.outline).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.sync_rounded,
                          size: 18,
                          color: syncProvider.serverReachable ? AppColors.secondary : AppColors.outline,
                        ),
                      ),
                tooltip: 'Sync Data',
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: _openSettings,
              icon: const Icon(Icons.settings_outlined, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _getScreens(context.watch<DashboardProvider>().isAdmin),
      ),
      bottomNavigationBar: Container(
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Consumer<DashboardProvider>(
          builder: (context, memberProvider, child) {
            final isAdmin = memberProvider.isAdmin;
            return ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.transparent,
                elevation: 0,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.grid_view_rounded),
                    activeIcon: Icon(Icons.grid_view_rounded),
                    label: 'Personal',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.people_outline_rounded),
                    activeIcon: Icon(Icons.people_rounded),
                    label: 'Dashboard',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline_rounded),
                    activeIcon: Icon(Icons.chat_bubble_rounded),
                    label: 'Chat',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.confirmation_number_outlined),
                    activeIcon: Icon(Icons.confirmation_number_rounded),
                    label: 'Tickets',
                  ),
                  if (isAdmin)
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_today_rounded),
                      activeIcon: Icon(Icons.calendar_today_rounded),
                      label: 'Onboarding',
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
