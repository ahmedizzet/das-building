import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/member.dart';
import '../providers/group_provider.dart';
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
          const SnackBar(
            content: Text('Internet connection is required to create or join a group.'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Building Group"),
        content: TextField(
          controller: _groupNameController,
          decoration: const InputDecoration(
            labelText: "Building Name",
            hintText: "e.g. Sunset Heights",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showJoinByCodeDialog() async {
    if (!await _checkConnection()) return;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Join by Invite Code"),
        content: TextField(
          controller: _inviteCodeController,
          decoration: const InputDecoration(
            labelText: "Invite Code",
            hintText: "6-character code",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = _inviteCodeController.text.trim().toUpperCase();
              if (code.isNotEmpty) {
                // Joining via code/QR grants 'member' (viewer) role
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
            child: const Text("Join"),
          ),
        ],
      ),
    );
  }

  void _showQRScanner() async {
    if (!await _checkConnection()) return;
    
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Scan Invite QR", style: AppTypography.headlineMd),
            ),
            Expanded(
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQRResult(String code) async {
    // Basic logic: if it's 6 chars, treat as invite code
    if (code.length == 6) {
      // Joining via QR grants 'member' (viewer) role
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
              const Icon(Icons.home_work_outlined, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                "Welcome to Civic Hearth",
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showCreateGroupDialog,
                  child: const Text("Create New Group"),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("OR"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showJoinByCodeDialog,
                  icon: const Icon(Icons.link_rounded),
                  label: const Text("Join with Invite Code"),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showQRScanner,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text("Scan Invitation QR"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
