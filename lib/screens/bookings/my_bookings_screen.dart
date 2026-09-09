import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/app_bottom_nav.dart';
import 'booking_details_screen.dart';

/// Second major feature: shows the full lifecycle of a user's bookings
/// (Confirmed / Completed / Cancelled) split into Upcoming and Past tabs,
/// closing the loop from booking to after-the-fact management as
/// described in the Assessment 3 usability goal.
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _BookingListView(bookings: provider.upcoming),
            _BookingListView(bookings: provider.past),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _BookingListView extends StatelessWidget {
  final List<Booking> bookings;
  const _BookingListView({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      // Graceful empty state per the non-functional requirement.
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('No bookings yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Your bookings will show up here.',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: bookings.length,
      itemBuilder: (context, i) {
        final b = bookings[i];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => BookingDetailsScreen(booking: b)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Image.network(
                    b.court.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64, height: 64, color: AppColors.primaryLight,
                      child: const Icon(Icons.sports_soccer, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.court.name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('MMM d, yyyy').format(b.date)}, ${b.timeSlot} • ${b.players} players',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: b.status),
              ],
            ),
          ),
        );
      },
    );
  }
}
