import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/status_badge.dart';

/// Full details for a single booking, with a Cancel action that updates
/// the booking's status in real time (via BookingProvider), completing
/// the "view and cancel upcoming or past bookings" functional requirement.
class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;
  const BookingDetailsScreen({super.key, required this.booking});

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Cancel booking?'),
        content: const Text('This action cannot be undone. Your slot will be released.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep booking'),
          ),
          TextButton(
            onPressed: () {
              context.read<BookingProvider>().cancelBooking(booking.id);
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Cancel booking', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider so status updates live if we navigate back here.
    final provider = context.watch<BookingProvider>();
    final current = provider.bookings.firstWhere((b) => b.id == booking.id, orElse: () => booking);

    return Scaffold(
      appBar: AppBar(title: const Text('Booking details')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    current.court.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.sports_soccer, size: 40, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(current.court.name, style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  StatusBadge(status: current.status),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadows.subtle,
                ),
                child: Column(
                  children: [
                    _row(Icons.calendar_today_rounded, 'Date and time',
                        '${DateFormat('EEE, MMM d, yyyy').format(current.date)} • ${current.timeSlot}'),
                    const SizedBox(height: 14),
                    _row(Icons.groups_rounded, 'Players', '${current.players}'),
                    const SizedBox(height: 14),
                    _row(Icons.payments_rounded, 'Total paid', '\$${current.total.toStringAsFixed(2)}'),
                    const SizedBox(height: 14),
                    _row(Icons.confirmation_number_rounded, 'Booking ID', current.id),
                  ],
                ),
              ),
              const Spacer(),
              if (current.status == BookingStatus.confirmed)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _confirmCancel(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                    child: const Text('Cancel booking', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}
