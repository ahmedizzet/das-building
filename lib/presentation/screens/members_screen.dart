import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/member.dart';
import '../providers/member_provider.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Member Collections", style: AppTypography.headlineLgMobile),
          const SizedBox(height: 16),
          const OctoberOverviewCard(),
          const SizedBox(height: 24),
          Text("Collections Trend", style: AppTypography.headlineMd),
          const SizedBox(height: 12),
          const CollectionsTrendChart(),
          const SizedBox(height: 24),
          const SearchAndFilterRow(),
          const SizedBox(height: 16),
          const MemberLedgerList(),
        ],
      ),
    );
  }
}

class OctoberOverviewCard extends StatelessWidget {
  const OctoberOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
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
              Text("October Overview", style: AppTypography.labelBold),
              Text("84% Collected", style: AppTypography.labelBold.copyWith(color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.84,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(label: "Total Dues", value: "\$42,000"),
              _StatItem(label: "Received", value: "\$35,280"),
              _StatItem(label: "Pending", value: "\$6,720"),
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

class CollectionsTrendChart extends StatelessWidget {
  const CollectionsTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(1, 4),
                FlSpot(2, 3.5),
                FlSpot(3, 5),
                FlSpot(4, 4.5),
                FlSpot(5, 6),
              ],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchAndFilterRow extends StatelessWidget {
  const SearchAndFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
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
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              FilterPill(label: 'All', isSelected: true),
              FilterPill(label: 'Paid', isSelected: false),
              FilterPill(label: 'Unpaid', isSelected: false),
              FilterPill(label: 'Late', isSelected: false),
            ],
          ),
        ),
      ],
    );
  }
}

class MemberLedgerList extends StatelessWidget {
  const MemberLedgerList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MemberProvider>(context);
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: provider.members.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final member = provider.members[index];
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
                backgroundImage: NetworkImage(member.imageUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                    Text(member.unit, style: AppTypography.bodySm),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    member.balance > 0 ? "\$${member.balance.toStringAsFixed(2)}" : "Paid",
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: member.status == PaymentStatus.paid ? AppColors.secondary : AppColors.onSurface,
                    ),
                  ),
                  if (member.status != PaymentStatus.paid)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: ElevatedButton(
                        onPressed: () => provider.nudgeMember(member.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryContainer,
                          foregroundColor: AppColors.onSecondaryContainer,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          minimumSize: const Size(60, 24),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text("Nudge", style: TextStyle(fontSize: 10)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  const FilterPill({super.key, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.labelBold.copyWith(
          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          fontSize: 11,
        ),
      ),
    );
  }
}
