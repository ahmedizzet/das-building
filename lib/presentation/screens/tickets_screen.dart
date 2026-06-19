import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/ticket.dart';
import '../providers/ticket_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/modern_components.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  void _showAddTicketSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Plumbing';
    final provider = Provider.of<TicketProvider>(context, listen: false);

    ModernBottomSheet.show(
      context,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
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
                  child: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Text("New Maintenance Ticket", style: AppTypography.headlineMd),
              ],
            ),
            const SizedBox(height: 20),
            ModernInputField(
              controller: titleController,
              label: 'Title',
              hintText: 'e.g. Leaking Pipe',
            ),
            const SizedBox(height: 12),
            ModernInputField(
              controller: descriptionController,
              label: 'Description',
              hintText: 'Describe the issue...',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  style: AppTypography.bodyLg,
                  items: ['Plumbing', 'Electrical', 'HVAC', 'General']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setSheetState(() => selectedCategory = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ModernButton(
              label: "Submit Ticket",
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  provider.addTicket(
                    title: titleController.text,
                    description: descriptionController.text,
                    category: selectedCategory,
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TicketProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: "Maintenance Tickets",
              subtitle: "Track and manage your service requests.",
            ),
            FilterPills(
              selectedFilter: provider.selectedFilter,
              onFilterSelected: provider.setSelectedFilter,
            ),
            const SizedBox(height: 16),
            if (provider.tickets.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.confirmation_number_outlined, size: 64, color: AppColors.outlineVariant),
                    const SizedBox(height: 16),
                    Text("No tickets yet", style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Text("Tap + to create a new ticket", style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              )
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: provider.tickets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return TicketCard(ticket: provider.tickets[index]);
                },
              ),
          ],
        ),
      ),
      floatingActionButton: context.watch<DashboardProvider>().isAdmin
          ? FloatingActionButton(
              heroTag: 'tickets_fab',
              onPressed: () => _showAddTicketSheet(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class FilterPills extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const FilterPills({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All Tickets', 'Open', 'In Progress', 'Resolved'];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((filter) {
          return ModernPill(
            label: filter,
            isSelected: selectedFilter == filter,
            onTap: () => onFilterSelected(filter),
          );
        }).toList(),
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(ticket.status);
    return GlassCard(
      accentColor: statusColor,
      padding: const EdgeInsets.all(0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withValues(alpha: 0.8),
                    statusColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_getIconForCategory(ticket.category), color: statusColor, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ticket.title, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text("${_formatDate(ticket.date)} • ${ticket.category}", style: AppTypography.bodySm),
                              const SizedBox(width: 8),
                              StatusIndicator(status: ticket.status == TicketStatus.pending ? 'pending' : ticket.status == TicketStatus.inProgress ? 'in progress' : 'resolved'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          StatusChip(status: ticket.status),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.outlineVariant, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return const Color(0xFF3B82F6);
      case TicketStatus.inProgress:
        return const Color(0xFFF59E0B);
      case TicketStatus.resolved:
        return AppColors.secondary;
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Plumbing':
        return Icons.water_drop_rounded;
      case 'Electrical':
        return Icons.lightbulb_rounded;
      case 'HVAC':
        return Icons.ac_unit_rounded;
      default:
        return Icons.confirmation_number_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}

class StatusChip extends StatelessWidget {
  final TicketStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bgColor;
    Color textColor;

    switch (status) {
      case TicketStatus.pending:
        label = 'Pending';
        bgColor = const Color(0xFF3B82F6).withValues(alpha: 0.1);
        textColor = const Color(0xFF1E3A8A);
        break;
      case TicketStatus.inProgress:
        label = 'In Progress';
        bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
        textColor = const Color(0xFF92400E);
        break;
      case TicketStatus.resolved:
        label = 'Resolved';
        bgColor = AppColors.secondary.withValues(alpha: 0.1);
        textColor = const Color(0xFF115E59);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusIndicator(status: label, size: 6),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelBold.copyWith(color: textColor, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
