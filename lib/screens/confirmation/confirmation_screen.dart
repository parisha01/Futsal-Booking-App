import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/booking.dart';
import '../home/home_screen.dart';
import '../bookings/booking_details_screen.dart';

/// Confirms the booking succeeded. The large checkmark, bold heading,
/// and higher-contrast body text are deliberate carry-overs from the
/// Assessment 3 design change made after Aisha's user-testing feedback
/// that the confirmed state wasn't unambiguous. The "Manage booking"
/// link is the same fix added after Priya's cancellation-discovery issue.
class ConfirmationScreen extends StatelessWidget {
  final Booking booking;
  const ConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: AppColors.success, size: 56),
              ),
              const SizedBox(height: 24),
              Text('Booking Confirmed',
                  style: Theme.of(context).textTheme.displaySmall, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'Your court is booked. See you on the pitch!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    _row('Court', booking.court.name),
                    const SizedBox(height: 10),
                    _row('Date', DateFormat('EEE, MMM d, yyyy').format(booking.date)),
                    const SizedBox(height: 10),
                    _row('Time', booking.timeSlot),
                    const SizedBox(height: 10),
                    _row('Players', '${booking.players}'),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                    _row('Total paid', '\$${booking.total.toStringAsFixed(2)}', bold: true),
                    const SizedBox(height: 10),
                    _row('Booking ID', booking.id, mono: true),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BookingDetailsScreen(booking: booking)),
                ),
                child: const Text(
                  'Manage booking',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, decoration: TextDecoration.underline),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, bool mono = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            fontSize: bold ? 16 : 14,
            color: bold ? AppColors.primaryDark : AppColors.textPrimary,
            fontFeatures: mono ? const [FontFeature.tabularFigures()] : null,
          ),
        ),
      ],
    );
  }
}
