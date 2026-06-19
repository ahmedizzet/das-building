import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/member.dart';
import '../providers/group_provider.dart';
import '../widgets/modern_components.dart';
import 'main_screen.dart';

class GroupLandingScreen extends StatefulWidget {
  final String phoneNumber;
  const GroupLandingScreen({super.key, required this.phoneNumber});

  @override
  State<GroupLandingScreen> createState() => _GroupLandingScreenState();
}

class _GroupLandingScreenState extends State<GroupLandingScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final groupProvider = context.read<GroupProvider>();
      await groupProvider.loadGroup();
      if (mounted && groupProvider.currentGroup != null) {
        _navigateToMain();
      }
    });
  }

  void _navigateToMain() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(phoneNumber: widget.phoneNumber),
      ),
      (route) => false,
    );
  }

  Future<bool> _checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Internet connection is required to create or join a group.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
    return true;
  }

  void _showCreateGroupDialog() async {
    if (!await _checkConnection()) return;
    if (!mounted) return;

    ModernDialog.show(
      context,
      title: "Create Building Group",
      icon: Icons.home_work_rounded,
      content: ModernInputField(
        controller: _groupNameController,
        label: "Building Name",
        hintText: "e.g. Sunset Heights",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = _groupNameController.text.trim();
            if (name.isNotEmpty) {
              await context.read<GroupProvider>().createGroup(name);
              if (mounted) {
                Navigator.pop(context);
                _navigateToMain();
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Create"),
        ),
      ],
    );
  }

  void _showJoinByCodeDialog() async {
    if (!await _checkConnection()) return;
    if (!mounted) return;

    ModernDialog.show(
      context,
      title: "Join by Invite Code",
      icon: Icons.link_rounded,
      content: ModernInputField(
        controller: _inviteCodeController,
        label: "Invite Code",
        hintText: "6-character code",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final code = _inviteCodeController.text.trim().toUpperCase();
            if (code.isNotEmpty) {
              final success = await context.read<GroupProvider>().joinGroupByCode(code, role: MemberRole.member);
              if (mounted) {
                if (success) {
                  Navigator.pop(context);
                  _navigateToMain();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid invite code')),
                  );
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Join"),
        ),
      ],
    );
  }

  void _showQRScanner() async {
    if (!await _checkConnection()) return;
    if (!mounted) return;

    ModernBottomSheet.show(
      context,
      maxHeight: 0.8,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text("Scan Invite QR", style: AppTypography.headlineMd),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final String? code = barcodes.first.rawValue;
                    if (code != null) {
                      Navigator.pop(context);
                      _handleQRResult(code);
                    }
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          ModernButton(
            label: "Cancel",
            isPrimary: false,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _handleQRResult(String code) async {
    if (code.length == 6) {
      final success = await context.read<GroupProvider>().joinGroupByCode(code, role: MemberRole.member);
      if (mounted) {
        if (success) {
          _navigateToMain();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid QR code')),
          );
        }
      }
    } else {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unsupported QR format')),
          );
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.home_work_outlined, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              Text(
                "Welcome to DAS Management",
                style: AppTypography.headlineLg,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "To get started, create a new building group or join an existing one. Internet is required for this step.",
                style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ModernButton(
                label: "Create New Group",
                icon: Icons.add_circle_outline,
                onPressed: _showCreateGroupDialog,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "OR",
                      style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              ModernButton(
                label: "Join with Invite Code",
                icon: Icons.link_rounded,
                isPrimary: false,
                onPressed: _showJoinByCodeDialog,
              ),
              const SizedBox(height: 12),
              ModernButton(
                label: "Scan Invitation QR",
                icon: Icons.qr_code_scanner_rounded,
                isPrimary: false,
                onPressed: _showQRScanner,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
