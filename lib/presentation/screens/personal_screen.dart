import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/personal_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../domain/entities/payment.dart';

class PersonalScreen extends StatelessWidget {
  const PersonalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<DashboardProvider>();
    final personalProvider = context.watch<PersonalProvider>();
    final currentUserId = memberProvider.currentUser?.id;
    final payments = currentUserId != null
        ? personalProvider.paymentsForMember(currentUserId)
        : <Payment>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("My Payments", style: AppTypography.headlineLgMobile),
          const SizedBox(height: 4),
          Text(
            "All payments you have made.",
            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          if (payments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.payment, size: 64, color: AppColors.outlineVariant),
                    const SizedBox(height: 16),
                    Text("No payments found", style: AppTypography.bodyLg),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: payments.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final payment = payments[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceContainer,
                    child: const Icon(Icons.payment, color: AppColors.primary),
                  ),
                  title: Text(
                    NumberFormat.currency(symbol: '\$').format(payment.amount),
                    style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(payment.date),
                    style: AppTypography.bodySm,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
            ),
        ],
      ),
    );
  }
}
