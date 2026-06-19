import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/dashboard_provider.dart';
import '../providers/group_provider.dart';
import '../providers/sync_provider.dart';
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("My Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${user?.name ?? 'Resident'}", style: AppTypography.bodyLg),
            const SizedBox(height: 8),
            if (user?.unit != null && user!.unit.isNotEmpty)
              Text("Unit: ${user.unit}", style: AppTypography.bodyLg),
            const SizedBox(height: 8),
            Text("Phone: ${user?.phoneNumber ?? widget.phoneNumber}", style: AppTypography.bodyLg),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openSettings();
            },
            child: const Text("Edit in Settings"),
          ),
        ],
      ),
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
                    : Icon(
                        Icons.sync_rounded,
                        color: syncProvider.serverReachable ? AppColors.secondary : AppColors.outline,
                      ),
                tooltip: 'Sync Data',
              );
            },
          ),
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _getScreens(context.watch<DashboardProvider>().isAdmin),
      ),
      bottomNavigationBar: Container(
        height: 84,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
        ),
        child: Consumer<DashboardProvider>(
          builder: (context, memberProvider, child) {
            final isAdmin = memberProvider.isAdmin;
            return BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Personal',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_rounded),
                  label: 'Dashboard',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  label: 'Chat',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.confirmation_number_outlined),
                  label: 'Tickets',
                ),
                if (isAdmin)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today_rounded),
                    label: 'Onboarding',
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
