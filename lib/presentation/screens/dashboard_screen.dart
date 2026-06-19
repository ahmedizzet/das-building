import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
          const RecentExpensesSection(),
          const SizedBox(height: 24),
          const MyPaymentHistorySection(),
        ],
      ),
    );
  }
}

class FinancialHeroCard extends StatelessWidget {
  const FinancialHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
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

class RecentExpensesSection extends StatelessWidget {
  const RecentExpensesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Building Expenses", style: AppTypography.headlineMd),
            IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
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
        Card(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: provider.expenses.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.surfaceContainer,
                  child: Icon(_getIconForCategory(expense.category), size: 20, color: AppColors.primary),
                ),
                title: Text(expense.title, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text("${expense.date} • ${expense.category}", style: AppTypography.bodySm),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(expense.amount, style: AppTypography.bodyLg),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {},
              );
            },
          ),
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

class MyPaymentHistorySection extends StatelessWidget {
  const MyPaymentHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("My Payment History", style: AppTypography.headlineMd),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              MonthPill(month: 'Aug', isSelected: false),
              MonthPill(month: 'Sep', isSelected: false),
              MonthPill(month: 'Oct', isSelected: true),
              MonthPill(month: 'Nov', isSelected: false),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Monthly Dues - October", style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                  Text("Due on Oct 31, 2023", style: AppTypography.bodySm),
                ],
              ),
              Text("\$350.00", style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainer,
              foregroundColor: AppColors.primary,
            ),
            child: const Text("Make a Payment"),
          ),
        ),
      ],
    );
  }
}

class MonthPill extends StatelessWidget {
  final String month;
  final bool isSelected;
  final VoidCallback? onTap;
  const MonthPill({super.key, required this.month, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
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
