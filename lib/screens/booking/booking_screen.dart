import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/court.dart';
import '../../providers/booking_provider.dart';
import '../payment/payment_screen.dart';

/// Core "complex process" screen: lets the user pick a date, a validated
/// AVAILABLE time slot (already-booked slots are disabled to prevent
/// double-booking the same venue/time — mirrors real-time availability
/// in apps like KheloMore/Playo), a player count with live dynamic price
/// calculation, and an optional promo code for a discount.
class BookingScreen extends StatefulWidget {
  final Court court;
  final String? preselectedSlot;
  const BookingScreen({super.key, required this.court, this.preselectedSlot});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late List<DateTime> _dateStrip;
  final _promoController = TextEditingController();
  String? _promoError;

  @override
  void initState() {
    super.initState();
    final provider = context.read<BookingProvider>();
    provider.startBooking(widget.court);
    if (widget.preselectedSlot != null &&
        !provider.isSlotTaken(widget.court, provider.selectedDate!, widget.preselectedSlot!)) {
      provider.updateSlot(widget.preselectedSlot!);
    }
    final today = DateTime.now();
    _dateStrip = List.generate(7, (i) => today.add(Duration(days: i)));
  }

  void _applyPromo(BookingProvider provider) {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    final applied = provider.applyPromoCode(code);
    setState(() => _promoError = applied ? null : 'Invalid or expired promo code');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final court = widget.court;
    const serviceFee = 2.0;
    final blocks = (provider.players / 5).ceil().clamp(1, 10);
    final courtRental = court.pricePerHour * blocks;
    final discount = courtRental * provider.appliedDiscount;
    final total = courtRental + serviceFee - discount;

    final slotTaken = provider.selectedDate != null &&
        provider.selectedSlot != null &&
        provider.isSlotTaken(court, provider.selectedDate!, provider.selectedSlot!);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm booking')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 140),
          children: [
            Text('Select date', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SizedBox(
              height: 68,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dateStrip.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final d = _dateStrip[i];
                  final selected = provider.selectedDate != null &&
                      d.day == provider.selectedDate!.day &&
                      d.month == provider.selectedDate!.month;
                  return GestureDetector(
                    onTap: () => provider.updateDate(d),
                    child: Container(
                      width: 56,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('EEE').format(d),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: selected ? Colors.white70 : AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(DateFormat('d').format(d),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text('Selected slot', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: slotTaken ? AppColors.dangerBg : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                    color: slotTaken
                        ? AppColors.danger.withValues(alpha: 0.4)
                        : AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    slotTaken ? Icons.event_busy_rounded : Icons.schedule_rounded,
                    color: slotTaken ? AppColors.danger : AppColors.primaryDark,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      slotTaken
                          ? '${court.name} • ${provider.selectedSlot} is already booked — pick another slot'
                          : '${court.name} • ${provider.selectedSlot ?? court.availableSlots.first}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: slotTaken ? AppColors.danger : AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: court.availableSlots.map((slot) {
                final selected = provider.selectedSlot == slot;
                final taken = provider.selectedDate != null &&
                    provider.isSlotTaken(court, provider.selectedDate!, slot);
                return Opacity(
                  opacity: taken ? 0.5 : 1,
                  child: ChoiceChip(
                    label: Text(taken ? '$slot • Booked' : slot),
                    selected: selected,
                    onSelected: taken ? null : (_) => provider.updateSlot(slot),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      decoration: taken ? TextDecoration.lineThrough : null,
                    ),
                    backgroundColor: taken ? AppColors.border : AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Number of players', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stepperButton(Icons.remove_rounded, () => provider.updatePlayers(provider.players - 1)),
                  Text('${provider.players}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  _stepperButton(Icons.add_rounded, () => provider.updatePlayers(provider.players + 1)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Promo code', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (provider.appliedPromoCode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer_rounded, size: 18, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${provider.appliedPromoCode} applied — ${(provider.appliedDiscount * 100).round()}% off',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.success),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        provider.clearPromoCode();
                        _promoController.clear();
                      },
                      child: const Icon(Icons.close_rounded, size: 18, color: AppColors.success),
                    ),
                  ],
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'e.g. FUTSAL10',
                        errorText: _promoError,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => _applyPromo(provider),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 28),
            Text('Price breakdown', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                children: [
                  _priceRow('Court rental (${blocks}x block, ${provider.players} players)',
                      '\$${courtRental.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _priceRow('Service fee', '\$${serviceFee.toStringAsFixed(2)}'),
                  if (discount > 0) ...[
                    const SizedBox(height: 8),
                    _priceRow('Discount (${provider.appliedPromoCode})',
                        '-\$${discount.toStringAsFixed(2)}', isDiscount: true),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  _priceRow('Total', '\$${total.toStringAsFixed(2)}', bold: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 12, AppSpacing.lg, 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, -3))],
        ),
        child: ElevatedButton(
          onPressed: slotTaken
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaymentScreen()),
                  ),
          child: Text(slotTaken ? 'Slot unavailable' : 'Confirm booking'),
        ),
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: bold ? 15 : 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? AppColors.textPrimary : AppColors.textSecondary,
            )),
        Text(value,
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: isDiscount
                  ? AppColors.success
                  : (bold ? AppColors.primaryDark : AppColors.textPrimary),
            )),
      ],
    );
  }
}
