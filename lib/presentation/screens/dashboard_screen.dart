import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/dashboard_provider.dart';
import '../providers/member_provider.dart';

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

  void _showAddExpenseSheet(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Maintenance';
    final provider = Provider.of<DashboardProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add New Expense", style: AppTypography.headlineMd),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Roof Repair'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount', hintText: 'e.g. 1200.00'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['Maintenance', 'Lifestyle', 'Operations', 'Utilities']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => selectedCategory = val!,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                    provider.addExpense(
                      title: titleController.text,
                      amount: -double.parse(amountController.text),
                      category: selectedCategory,
                      date: DateTime.now(),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save Expense"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sort Expenses", style: AppTypography.headlineMd),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text("Date (Newest)"),
              onTap: () { Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text("Date (Oldest)"),
              onTap: () { Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text("Amount (Highest)"),
              onTap: () { Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text("Amount (Lowest)"),
              onTap: () { Navigator.pop(context); },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

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
            Row(
              children: [
                if (context.watch<MemberProvider>().isAdmin)
                  IconButton(
                    onPressed: () => _showAddExpenseSheet(context),
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                  ),
                IconButton(
                  onPressed: () => _showFilterSheet(context),
                  icon: const Icon(Icons.tune),
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
                subtitle: Text("${DateFormat('MMM dd').format(expense.date)} • ${expense.category}", style: AppTypography.bodySm),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NumberFormat.currency(symbol: '\$').format(expense.amount),
                      style: AppTypography.bodyLg.copyWith(
                        color: expense.amount < 0 ? AppColors.onSurface : AppColors.secondary,
                      ),
                    ),
                    const Icon(Icons.chevron_right),
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.title, style: AppTypography.headlineMd),
            const SizedBox(height: 12),
            Text("Amount: ${NumberFormat.currency(symbol: '\$').format(expense.amount)}", style: AppTypography.bodyLg),
            const SizedBox(height: 8),
            Text("Date: ${DateFormat('MMM dd, yyyy').format(expense.date)}", style: AppTypography.bodyLg),
            const SizedBox(height: 8),
            Text("Category: ${expense.category}", style: AppTypography.bodyLg),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
