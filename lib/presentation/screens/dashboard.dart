import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/payment.dart';
import '../providers/dashboard_provider.dart';
import '../providers/personal_provider.dart';
import '../widgets/modern_components.dart';

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

    ModernBottomSheet.show(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Record Payment", style: AppTypography.headlineMd),
          const SizedBox(height: 20),
          ModernDropdownField<String>(
            value: selectedMemberId,
            label: 'Member',
            items: members
                .map(
                  (m) => DropdownMenuItem(
                    value: m.id,
                    child: Text("${m.name} — ${m.unit}"),
                  ),
                )
                .toList(),
            onChanged: (val) => selectedMemberId = val,
          ),
          const SizedBox(height: 12),
          ModernInputField(
            controller: amountController,
            label: 'Amount',
            hintText: 'e.g. 350.00',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          ModernButton(
            label: "Record Payment",
            onPressed: () async {
              if (selectedMemberId == null || amountController.text.isEmpty)
                return;
              await provider.recordPayment(
                memberId: selectedMemberId!,
                amount: double.parse(amountController.text),
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Payment recorded'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final monthLabel = DateFormat(
      'MMMM yyyy',
    ).format(DateTime(provider.targetYear, provider.targetMonth));

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: "Financial Overview",
              subtitle: "Building financial status and personal dues.",
            ),
            const SizedBox(height: 4),
            const FinancialHeroCard(),
            const SizedBox(height: 24),
            const RecentExpensesSection(),
            const SizedBox(height: 24),
            Text("Member Collections", style: AppTypography.headlineLgMobile),
            const SizedBox(height: 16),
            _MonthOverviewCard(
              monthLabel: monthLabel,
              total: provider.allMembers.length,
              paid: provider.allMembers
                  .where((m) => provider.isMemberPaidInSelectedMonth(m.id))
                  .length,
            ),
            const SizedBox(height: 24),
            Text(
              "Select Month",
              style: AppTypography.labelBold.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.months.length,
                itemBuilder: (context, index) {
                  final month = provider.months[index];
                  final isSelected = provider.selectedMonth == month;
                  return ModernPill(
                    label: month,
                    isSelected: isSelected,
                    onTap: () => provider.setSelectedMonth(month),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ModernPill(
                  label: 'Paid',
                  isSelected: provider.selectedFilter == 'Paid',
                  onTap: () => provider.setSelectedPaymentFilter('Paid'),
                ),
                const SizedBox(width: 8),
                ModernPill(
                  label: 'Unpaid',
                  isSelected: provider.selectedFilter == 'Unpaid',
                  onTap: () => provider.setSelectedPaymentFilter('Unpaid'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ModernInputField(
              controller: TextEditingController(),
              label: '',
              hintText: "Search resident or unit...",
              prefixIcon: const Icon(Icons.search, size: 20),
              onChanged: (value) => provider.setSearchQuery(value),
            ),
            const SizedBox(height: 16),
            if (provider.members.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: AppColors.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.selectedFilter == 'Paid'
                          ? "No members have paid this month"
                          : "All members have paid this month",
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: provider.members.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final member = provider.members[index];
                  final payments = provider.paymentsForMemberInSelectedMonth(
                    member.id,
                  );
                  return _MemberPaymentCard(
                    member: member,
                    payments: payments,
                    isAdmin: provider.isAdmin,
                    onNudge: () {
                      provider.nudgeMember(member.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Nudge sent to ${member.name}"),
                          backgroundColor: AppColors.secondary,
                        ),
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
              child: const Icon(Icons.payments_rounded),
            )
          : null,
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
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(monthLabel, style: AppTypography.labelBold),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${(pct * 100).toInt()}% Collected",
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.secondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
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
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700),
        ),
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
    return GlassCard(
      accentColor: hasPaid ? AppColors.secondary : null,
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
                Text(
                  member.name,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(member.unit, style: AppTypography.bodySm),
                if (hasPaid)
                  ...payments.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "\$${p.amount.toStringAsFixed(2)} • ${DateFormat('MMM dd, h:mm a').format(p.date)}",
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.secondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class FinancialHeroCard extends StatelessWidget {
  const FinancialHeroCard({super.key});

  void _showEditBalanceDialog(BuildContext context) {
    final provider = context.read<PersonalProvider>();
    final controller = TextEditingController(
      text: provider.buildingBalance.toStringAsFixed(2),
    );

    ModernDialog.show(
      context,
      title: "Edit Building Balance",
      icon: Icons.account_balance_rounded,
      content: ModernInputField(
        controller: controller,
        label: "Total Building Balance",
        keyboardType: TextInputType.number,
        prefixText: "\$ ",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.onSurfaceVariant,
          ),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final value = double.tryParse(controller.text);
            if (value != null) {
              provider.setBuildingBalance(value);
            }
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Save"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PersonalProvider>(context);
    final isAdmin = context.watch<DashboardProvider>().isAdmin;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF00288E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Total Building Balance",
                style: AppTypography.labelBold.copyWith(color: Colors.white70),
              ),
              const Spacer(),
              if (isAdmin)
                GestureDetector(
                  onTap: () => _showEditBalanceDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "\$${provider.buildingBalance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
            style: AppTypography.financialDisplay.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monthly Income",
                      style: AppTypography.labelBold.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "+\$${provider.monthlyIncome.toStringAsFixed(2)}",
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.secondaryFixed,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monthly Expenses",
                      style: AppTypography.labelBold.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "-\$${provider.monthlyExpenses.toStringAsFixed(2)}",
                      style: AppTypography.headlineMd.copyWith(
                        color: const Color(0xFFFCA5A5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => provider.downloadReport(),
              icon: const Icon(Icons.download, size: 18),
              label: const Text("Download Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecentExpensesSection extends StatelessWidget {
  const RecentExpensesSection({super.key});

  void _showAddExpenseSheet(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Maintenance';
    final provider = Provider.of<PersonalProvider>(context, listen: false);

    ModernBottomSheet.show(
      context,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add New Expense", style: AppTypography.headlineMd),
            const SizedBox(height: 20),
            ModernInputField(
              controller: titleController,
              label: 'Title',
              hintText: 'e.g. Roof Repair',
            ),
            const SizedBox(height: 12),
            ModernInputField(
              controller: amountController,
              label: 'Amount',
              hintText: 'e.g. 1200.00',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  style: AppTypography.bodyLg,
                  items: ['Maintenance', 'Lifestyle', 'Operations', 'Utilities']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) =>
                      setSheetState(() => selectedCategory = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ModernButton(
              label: "Save Expense",
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  provider.addExpense(
                    title: titleController.text,
                    amount: -double.parse(amountController.text),
                    category: selectedCategory,
                    date: DateTime.now(),
                  );
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    ModernBottomSheet.show(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sort Expenses", style: AppTypography.headlineMd),
          const SizedBox(height: 16),
          GlassCard(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.date_range,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text("Date (Newest)", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GlassCard(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.date_range,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text("Date (Oldest)", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GlassCard(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.attach_money,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text("Amount (Highest)", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GlassCard(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.attach_money,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text("Amount (Lowest)", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PersonalProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Building Expenses",
                style: AppTypography.headlineMd,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                if (context.watch<DashboardProvider>().isAdmin)
                  IconButton(
                    onPressed: () => _showAddExpenseSheet(context),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                    ),
                  ),
                IconButton(
                  onPressed: () => _showFilterSheet(context),
                  icon: const Icon(
                    Icons.tune,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.months.length,
            itemBuilder: (context, index) {
              final month = provider.months[index];
              return MonthPill(
                month: month,
                isSelected: provider.selectedExpenseMonth == month,
                onTap: () => provider.setSelectedExpenseMonth(month),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: provider.expenses.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForCategory(expense.category),
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  expense.title,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  "${DateFormat('MMM dd').format(expense.date)} • ${expense.category}",
                  style: AppTypography.bodySm,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NumberFormat.currency(
                        symbol: '\$',
                      ).format(expense.amount),
                      style: AppTypography.bodyLg.copyWith(
                        color: expense.amount < 0
                            ? AppColors.onSurface
                            : AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.outlineVariant,
                      size: 20,
                    ),
                  ],
                ),
                onTap: () => _showExpenseDetail(context, expense),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showExpenseDetail(BuildContext context, dynamic expense) {
    ModernBottomSheet.show(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForCategory(expense.category),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(expense.title, style: AppTypography.headlineMd),
            ],
          ),
          const SizedBox(height: 20),
          _detailRow(
            "Amount",
            NumberFormat.currency(symbol: '\$').format(expense.amount),
          ),
          const SizedBox(height: 8),
          _detailRow("Date", DateFormat('MMM dd, yyyy').format(expense.date)),
          const SizedBox(height: 8),
          _detailRow("Category", expense.category),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Maintenance':
        return Icons.build_rounded;
      case 'Lifestyle':
        return Icons.spa_rounded;
      case 'Operations':
        return Icons.business_center_rounded;
      case 'Utilities':
        return Icons.water_drop_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}

class MonthPill extends StatelessWidget {
  final String month;
  final bool isSelected;
  final VoidCallback? onTap;
  const MonthPill({
    super.key,
    required this.month,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.9),
                    AppColors.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          month,
          style: AppTypography.labelBold.copyWith(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
