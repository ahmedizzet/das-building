import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/ticket.dart';
import '../providers/ticket_provider.dart';
import '../providers/member_provider.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  void _showAddTicketSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Plumbing';
    final provider = Provider.of<TicketProvider>(context, listen: false);

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
            Text("New Maintenance Ticket", style: AppTypography.headlineMd),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Leaking Pipe'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description', hintText: 'Describe the issue...'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['Plumbing', 'Electrical', 'HVAC', 'General']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => selectedCategory = val!,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                child: const Text("Submit Ticket"),
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
    final provider = Provider.of<TicketProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Maintenance Tickets", style: AppTypography.headlineLgMobile),
            const SizedBox(height: 4),
            Text("Track and manage your service requests.", style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 16),
            FilterPills(
              selectedFilter: provider.selectedFilter,
              onFilterSelected: provider.setSelectedFilter,
            ),
            const SizedBox(height: 16),
            if (provider.tickets.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
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
      floatingActionButton: context.watch<MemberProvider>().isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddTicketSheet(context),
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
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
          return GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selectedFilter == filter ? AppColors.primary : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter,
                style: AppTypography.labelBold.copyWith(
                  color: selectedFilter == filter ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
            ),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: _getStatusColor(ticket.status),
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
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getIconForCategory(ticket.category), color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ticket.title, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                          Text("${_formatDate(ticket.date)} • ${ticket.category}", style: AppTypography.bodySm),
                          const SizedBox(height: 8),
                          StatusChip(status: ticket.status),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.outlineVariant),
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
        return Colors.blue;
      case TicketStatus.inProgress:
        return Colors.orange;
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
        bgColor = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF1E3A8A);
        break;
      case TicketStatus.inProgress:
        label = 'In Progress';
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
      case TicketStatus.resolved:
        label = 'Resolved';
        bgColor = const Color(0xFFCCFBF1);
        textColor = const Color(0xFF115E59);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: AppTypography.labelBold.copyWith(color: textColor, fontSize: 10),
      ),
    );
  }
}
