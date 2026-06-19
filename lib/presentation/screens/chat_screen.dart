import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Community Chat", style: AppTypography.headlineLgMobile),
          const SizedBox(height: 16),
          const SegmentedControl(),
          const SizedBox(height: 24),
          const PinnedAnnouncementCard(),
          const SizedBox(height: 24),
          const FeedEventCard(
            title: "Rooftop Yoga Session",
            category: "Lifestyle • Group Event",
            time: "Tomorrow, 8:00 AM",
            imageUrl: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=60",
          ),
          const SizedBox(height: 16),
          const FeedEventCard(
            title: "Weekend Community BBQ",
            category: "Social • Resident Led",
            time: "Sat, Oct 21, 5:00 PM",
            imageUrl: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=60",
          ),
        ],
      ),
    );
  }
}

class SegmentedControl extends StatelessWidget {
  const SegmentedControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text("Announcements", style: AppTypography.labelBold.copyWith(color: AppColors.primary)),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Text("Lounge", style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant)),
            ),
          ),
        ],
      ),
    );
  }
}

class PinnedAnnouncementCard extends StatelessWidget {
  const PinnedAnnouncementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.push_pin_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text("PINNED ANNOUNCEMENT", style: AppTypography.labelBold.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Text("Elevator Maintenance Notice", style: AppTypography.headlineMd),
          const SizedBox(height: 4),
          Text(
            "Service scheduled for North Wing elevators on Oct 25 from 10 AM to 2 PM. Please use South Wing elevators.",
            style: AppTypography.bodyLg,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(radius: 12, backgroundColor: AppColors.surfaceDim, child: Icon(Icons.business, size: 14)),
              const SizedBox(width: 8),
              Text("Property Management • 2 days ago", style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class FeedEventCard extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final String imageUrl;

  const FeedEventCard({
    super.key,
    required this.title,
    required this.category,
    required this.time,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 160,
              color: AppColors.surfaceDim,
              child: const Icon(Icons.image, size: 48, color: AppColors.onSurfaceVariant),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: AppTypography.labelBold.copyWith(color: AppColors.secondary)),
                const SizedBox(height: 4),
                Text(title, style: AppTypography.headlineMd),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(time, style: AppTypography.bodySm),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
