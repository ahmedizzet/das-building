import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/onboarding_provider.dart';
import '../providers/group_provider.dart';
import '../widgets/modern_components.dart';
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
    ModernDialog.show(
      context,
      title: "Assign Monthly Fee",
      icon: Icons.attach_money_rounded,
      content: ModernInputField(
        controller: controller,
        label: "Monthly Fee (EGP)",
        keyboardType: TextInputType.number,
        prefixText: "EGP ",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final fee = double.tryParse(controller.text) ?? 0.0;
            context.read<OnboardingProvider>().updateMonthlyFee(memberId, fee);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Update"),
        ),
      ],
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
                const SectionHeader(
                  title: "Manage residents",
                  subtitle: "Share the building QR code with residents so they can join.",
                ),
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
                  
                  return GlassCard(
                    padding: const EdgeInsets.all(12),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "EGP ${gm.monthlyFee.toStringAsFixed(0)}/mo",
                                style: AppTypography.labelBold.copyWith(color: AppColors.primary, fontSize: 11),
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => _showFeeDialog(gm.memberId, gm.monthlyFee),
                              child: Text(
                                "Edit Fee",
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
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
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
          ),
          const SizedBox(height: 16),
          Text("No Building Group Found", style: AppTypography.headlineMd),
          const SizedBox(height: 8),
          Text(
            "It seems you are not associated with a building group yet.",
            style: AppTypography.bodySm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ModernButton(
            label: "Retry Loading",
            onPressed: () => context.read<GroupProvider>().loadGroup(),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(String code) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Text("Building QR Code", style: AppTypography.headlineMd),
            ],
          ),
          const SizedBox(height: 20),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: QrImageView(
              data: code,
              version: QrVersions.auto,
              size: 200.0,
              foregroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text("Invite Code", style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            code,
            style: AppTypography.headlineMd.copyWith(
              letterSpacing: 4,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          ModernButton(
            label: "Share Invitation",
            icon: Icons.share_rounded,
            onPressed: () => _shareInviteLink(code),
          ),
        ],
      ),
    );
  }
}
