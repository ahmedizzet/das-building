import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/onboarding_provider.dart';
import '../providers/group_provider.dart';
import '../../domain/entities/member.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupProvider = context.read<GroupProvider>();
      if (groupProvider.currentGroup == null) {
        groupProvider.loadGroup();
      }
    });
  }

  void _showFeeDialog(String memberId, double currentFee) {
    final controller = TextEditingController(text: currentFee.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Assign Monthly Fee"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Monthly Fee (EGP)",
            prefixText: "EGP",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final fee = double.tryParse(controller.text) ?? 0.0;
              context.read<OnboardingProvider>().updateMonthlyFee(memberId, fee);
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _shareInviteLink(String code) {
    Share.share("Join our building group on DAS Management! Use this code to join: $code");
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final groupProvider = context.watch<GroupProvider>();
    final group = groupProvider.currentGroup;

    return Scaffold(
      body: groupProvider.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Manage residents", style: AppTypography.headlineLgMobile),
                const SizedBox(height: 8),
                Text(
                  "Share the building QR code with residents so they can join.",
                  style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),

                if (group != null) ...[
                  _buildInviteCard(group.inviteCode),
                  const SizedBox(height: 24),
                ] else ...[
                   _buildNoGroupState(),
                   const SizedBox(height: 24),
                ],
            
            const SizedBox(height: 8),
            Text("Building Members", style: AppTypography.headlineMd),
            const SizedBox(height: 16),

            if (provider.groupMembers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "No residents added yet.",
                    style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.groupMembers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final gm = provider.groupMembers[index];
                  final details = provider.getMemberDetails(gm.memberId);
                  
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: details?.imageUrl != null 
                              ? NetworkImage(details!.imageUrl) 
                              : null,
                          child: details?.imageUrl == null ? const Icon(Icons.person) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                details?.name ?? "Unknown Resident",
                                style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                details?.unit ?? "No unit info",
                                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "EGP ${gm.monthlyFee.toStringAsFixed(0)}/mo",
                              style: AppTypography.labelBold.copyWith(color: AppColors.primary),
                            ),
                            TextButton(
                              onPressed: () => _showFeeDialog(gm.memberId, gm.monthlyFee),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Edit Fee",
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.secondary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoGroupState() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text("No Building Group Found", style: AppTypography.headlineMd),
          const SizedBox(height: 8),
          Text(
            "It seems you are not associated with a building group yet.",
            style: AppTypography.bodySm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<GroupProvider>().loadGroup(),
            child: const Text("Retry Loading"),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(String code) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
               const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 24),
               const SizedBox(width: 12),
               Text("Building QR Code", style: AppTypography.headlineMd),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: QrImageView(
                data: code,
                version: QrVersions.auto,
                size: 200.0,
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text("Invite Code", style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(code, style: AppTypography.headlineMd.copyWith(letterSpacing: 4, color: AppColors.primary)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _shareInviteLink(code),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text("Share Invitation"),
            ),
          ),
        ],
      ),
    );
  }
}
