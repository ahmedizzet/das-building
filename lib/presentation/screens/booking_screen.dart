import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Reserve an Amenity", style: AppTypography.headlineLgMobile),
          const SizedBox(height: 16),
          const PolicyBanner(),
          const SizedBox(height: 24),
          Text("Select Amenity", style: AppTypography.headlineMd),
          const SizedBox(height: 12),
          const AmenityCarousel(),
          const SizedBox(height: 24),
          Text("Select Date", style: AppTypography.headlineMd),
          const SizedBox(height: 12),
          const DateStrip(),
          const SizedBox(height: 24),
          Text("Available Time Slots", style: AppTypography.headlineMd),
          const SizedBox(height: 12),
          const TimeSlotsGrid(),
          const SizedBox(height: 32),
          const BookingSummaryBanner(),
        ],
      ),
    );
  }
}

class PolicyBanner extends StatelessWidget {
  const PolicyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Bookings must be made 24 hours in advance. Cancellation fees may apply.",
              style: AppTypography.bodySm,
            ),
          ),
        ],
      ),
    );
  }
}

class AmenityCarousel extends StatelessWidget {
  const AmenityCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          AmenityCard(title: "Gym", imageUrl: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=60", isSelected: true),
          AmenityCard(title: "Pool", imageUrl: "https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=60", isSelected: false),
          AmenityCard(title: "Lounge", imageUrl: "https://images.unsplash.com/photo-1517502884422-41eaadeff171?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=60", isSelected: false),
        ],
      ),
    );
  }
}

class AmenityCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isSelected;
  const AmenityCard({super.key, required this.title, required this.imageUrl, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(12),
        alignment: Alignment.bottomLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTypography.labelBold.copyWith(color: Colors.white)),
            if (isSelected)
              const CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.check, size: 12, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

class DateStrip extends StatelessWidget {
  const DateStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final isSelected = index == 2;
          return Container(
            width: 60,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Mon", style: AppTypography.bodySm.copyWith(color: isSelected ? Colors.white70 : AppColors.onSurfaceVariant)),
                Text("${16 + index}", style: AppTypography.headlineMd.copyWith(color: isSelected ? Colors.white : AppColors.onSurface)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TimeSlotsGrid extends StatelessWidget {
  const TimeSlotsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 2.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: const [
        TimeSlot(time: "09:00 AM", status: "available"),
        TimeSlot(time: "10:00 AM", status: "booked"),
        TimeSlot(time: "11:00 AM", status: "available"),
        TimeSlot(time: "12:00 PM", status: "selected"),
        TimeSlot(time: "01:00 PM", status: "available"),
        TimeSlot(time: "02:00 PM", status: "available"),
      ],
    );
  }
}

class TimeSlot extends StatelessWidget {
  final String time;
  final String status;
  const TimeSlot({super.key, required this.time, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BoxBorder? border;

    switch (status) {
      case "selected":
        bgColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case "booked":
        bgColor = Colors.transparent;
        textColor = AppColors.outline;
        border = Border.all(color: AppColors.outlineVariant);
        break;
      default:
        bgColor = AppColors.background;
        textColor = AppColors.onSurface;
        border = Border.all(color: AppColors.outlineVariant);
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(time, style: AppTypography.labelBold.copyWith(color: textColor)),
          if (status == "booked")
            Transform.rotate(
              angle: -0.5,
              child: Container(height: 1, width: 40, color: AppColors.outlineVariant),
            ),
        ],
      ),
    );
  }
}

class BookingSummaryBanner extends StatelessWidget {
  const BookingSummaryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Gym • Oct 18", style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant)),
              Text("12:00 PM - 01:00 PM", style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Book Now"),
          ),
        ],
      ),
    );
  }
}
