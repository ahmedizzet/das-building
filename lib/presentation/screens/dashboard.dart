import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/payment.dart';
import '../providers/dashboard_provider.dart';
import '../providers/personal_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MembersBody();
  }
}

class _MembersBody extends StatelessWidget {
  const _MembersBody();

  void _showRecordPaymentSheet(BuildContext context) {
    final provider = context.read<DashboardProvider>();
    final members = provider.allMembers;
    String? selectedMemberId;
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Record Payment", style: AppTypography.headlineMd),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedMemberId,
              decoration: const InputDecoration(labelText: 'Member'),
              items: members.map((m) =>
                DropdownMenuItem(value: m.id, child: Text("${m.name} — ${m.unit}"))
              ).toList(),
              onChanged: (val) => selectedMemberId = val,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount', hintText: 'e.g. 350.00'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedMemberId == null || amountController.text.isEmpty) return;
                  await provider.recordPayment(
                    memberId: selectedMemberId!,
                    amount: double.parse(amountController.text),
                  );
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment recorded')),
                  );
                },
                child: const Text("Record Payment"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime(provider.targetYear, provider.targetMonth));

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Financial Overview", style: AppTypography.headlineLgMobile),
            const SizedBox(height: 4),
            Text(
              "Building financial status and personal dues.",
              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            const FinancialHeroCard(),
            const SizedBox(height: 24),
            Text("Member Collections", style: AppTypography.headlineLgMobile),
            const SizedBox(height: 16),
            _MonthOverviewCard(
              monthLabel: monthLabel,
              total: provider.allMembers.length,
              paid: provider.allMembers.where((m) => provider.isMemberPaidInSelectedMonth(m.id)).length,
            ),
            const SizedBox(height: 24),
            Text("Select Month", style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.months.length,
                itemBuilder: (context, index) {
                  final month = provider.months[index];
                  final isSelected = provider.selectedMonth == month;
                  return GestureDetector(
                    onTap: () => provider.setSelectedMonth(month),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        month,
                        style: AppTypography.labelBold.copyWith(
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _FilterChip(
                  label: 'Paid',
                  isSelected: provider.selectedFilter == 'Paid',
                  onTap: () => provider.setSelectedPaymentFilter('Paid'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Unpaid',
                  isSelected: provider.selectedFilter == 'Unpaid',
                  onTap: () => provider.setSelectedPaymentFilter('Unpaid'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => provider.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: "Search resident or unit...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (provider.members.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                width: double.infinity,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 64, color: AppColors.outlineVariant),
                    const SizedBox(height: 16),
                    Text(
                      provider.selectedFilter == 'Paid'
                          ? "No members have paid this month"
                          : "All members have paid this month",
                      style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: provider.members.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final member = provider.members[index];
                  final payments = provider.paymentsForMemberInSelectedMonth(member.id);
                  return _MemberPaymentCard(
                    member: member,
                    payments: payments,
                    isAdmin: provider.isAdmin,
                    onNudge: () {
                      provider.nudgeMember(member.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Nudge sent to ${member.name}")),
                      );
                    },
                  );
                },
              ),
    SizedBox(height: 50),
          ],

        ),
      ),
      floatingActionButton: provider.isAdmin
          ? FloatingActionButton(
              heroTag: 'members_fab',
              onPressed: () => _showRecordPaymentSheet(context),
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              child: const Icon(Icons.payments_rounded),
            )
          : null,
    );

  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.labelBold.copyWith(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MonthOverviewCard extends StatelessWidget {
  final String monthLabel;
  final int total;
  final int paid;

  const _MonthOverviewCard({
    required this.monthLabel,
    required this.total,
    required this.paid,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? paid / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(monthLabel, style: AppTypography.labelBold),
              Text("${(pct * 100).toInt()}% Collected",
                  style: AppTypography.labelBold.copyWith(color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(label: "Total Members", value: "$total"),
              _StatItem(label: "Paid", value: "$paid"),
              _StatItem(label: "Pending", value: "${total - paid}"),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
        Text(value, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _MemberPaymentCard extends StatelessWidget {
  final Member member;
  final List<Payment> payments;
  final bool isAdmin;
  final VoidCallback onNudge;

  const _MemberPaymentCard({
    required this.member,
    required this.payments,
    required this.isAdmin,
    required this.onNudge,
  });

  @override
  Widget build(BuildContext context) {
    final hasPaid = payments.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasPaid ? AppColors.secondary.withValues(alpha: 0.3) : AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(member.imageUrl),
            onBackgroundImageError: (_, __) {},
            child: Text(member.name.isNotEmpty ? member.name[0] : '?'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                Text(member.unit, style: AppTypography.bodySm),
                if (hasPaid)
                  ...payments.map((p) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          "\$${p.amount.toStringAsFixed(2)} • ${DateFormat('MMM dd, h:mm a').format(p.date)}",
                          style: AppTypography.bodySm.copyWith(color: AppColors.secondary, fontSize: 11),
                        ),
                      ],
                    ),
                  )),
              ],
            ),
          ),
          if (!hasPaid && isAdmin)
            TextButton(
              onPressed: onNudge,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 32),
              ),
              child: const Text("Nudge", style: TextStyle(fontSize: 12)),
            ),
          if (hasPaid)
            const Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
        ],
      ),
    );
  }
}

class FinancialHeroCard extends StatelessWidget {
  const FinancialHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PersonalProvider>(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF00288E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Building Balance",
            style: AppTypography.labelBold.copyWith(color: AppColors.onPrimaryContainer),
          ),
          Text(
            "\$${provider.buildingBalance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
            style: AppTypography.financialDisplay.copyWith(color: AppColors.onPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            "Monthly Income (Est)",
            style: AppTypography.labelBold.copyWith(color: AppColors.onPrimaryContainer),
          ),
          Text(
            "+\$${provider.monthlyIncome.toStringAsFixed(2)}",
            style: AppTypography.headlineMd.copyWith(color: AppColors.secondaryFixed),
          ),
          const SizedBox(height: 12),
          Text(
            "Monthly Expenses (YTD Avg)",
            style: AppTypography.labelBold.copyWith(color: AppColors.onPrimaryContainer),
          ),
          Text(
            "-\$${provider.monthlyExpenses.toStringAsFixed(2)}",
            style: AppTypography.headlineMd.copyWith(color: AppColors.errorContainer),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.downloadReport(),
            icon: const Icon(Icons.download),
            label: const Text("Download Report"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
