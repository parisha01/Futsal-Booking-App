import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../confirmation/confirmation_screen.dart';

/// Payment method selection + entry, with real field validation for the
/// card option (number length, expiry format, CVV length) so "Pay now"
/// only proceeds with plausible input — matching the "choose a payment
/// method and complete payment" functional requirement properly rather
/// than accepting anything typed.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  String? _validateCardNumber(String? v) {
    final digits = (v ?? '').replaceAll(' ', '');
    if (digits.isEmpty) return 'Card number is required';
    if (digits.length < 16) return 'Enter a valid 16-digit card number';
    if (!RegExp(r'^\d+$').hasMatch(digits)) return 'Digits only';
    return null;
  }

  String? _validateExpiry(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(v)) return 'Use MM/YY';
    final parts = v.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');
    final now = DateTime.now();
    final expiry = DateTime(year, month + 1, 0);
    if (expiry.isBefore(now)) return 'Card has expired';
    return null;
  }

  String? _validateCvv(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (!RegExp(r'^\d{3,4}$').hasMatch(v)) return '3-4 digits';
    return null;
  }

  void _handlePay(BookingProvider provider) {
    final isCard = provider.paymentMethod == PaymentMethod.card;
    if (isCard && !(_formKey.currentState?.validate() ?? false)) {
      return; // Stop here — invalid card details, do not proceed.
    }
    try {
      final booking = provider.confirmBooking();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ConfirmationScreen(booking: booking)),
      );
    } on StateError catch (e) {
      // Defensive: the slot was taken between Booking and Payment steps.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final court = provider.selectedCourt!;
    final blocks = (provider.players / 5).ceil().clamp(1, 10);
    final courtRental = court.pricePerHour * blocks;
    const serviceFee = 2.0;
    final discount = courtRental * provider.appliedDiscount;
    final total = courtRental + serviceFee - discount;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 140),
            children: [
              Text('Payment method', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _methodTile(
                context,
                method: PaymentMethod.card,
                icon: Icons.credit_card_rounded,
                label: 'Credit / Debit card',
                selected: provider.paymentMethod,
              ),
              const SizedBox(height: 10),
              _methodTile(
                context,
                method: PaymentMethod.paypal,
                icon: Icons.account_balance_wallet_rounded,
                label: 'PayPal',
                selected: provider.paymentMethod,
              ),
              const SizedBox(height: 10),
              _methodTile(
                context,
                method: PaymentMethod.cash,
                icon: Icons.payments_rounded,
                label: 'Cash on arrival',
                selected: provider.paymentMethod,
              ),
              if (provider.paymentMethod == PaymentMethod.card) ...[
                const SizedBox(height: 24),
                Text('Card number', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                  ],
                  decoration: const InputDecoration(hintText: '1234567890123456'),
                  validator: _validateCardNumber,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MM/YY', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _expiryController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              _ExpiryDateFormatter(),
                            ],
                            decoration: const InputDecoration(hintText: '08/28'),
                            validator: _validateExpiry,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CVV', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _cvvController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: const InputDecoration(hintText: '123'),
                            validator: _validateCvv,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 28),
              Text('Order summary', style: Theme.of(context).textTheme.titleMedium),
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
                    _row('Court rental (${court.pricePerHour.toStringAsFixed(0)}/hr)',
                        '\$${courtRental.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _row('Service fee', '\$${serviceFee.toStringAsFixed(2)}'),
                    if (discount > 0) ...[
                      const SizedBox(height: 8),
                      _row('Discount (${provider.appliedPromoCode})',
                          '-\$${discount.toStringAsFixed(2)}'),
                    ],
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                    _row('Total', '\$${total.toStringAsFixed(2)}', bold: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 12, AppSpacing.lg, 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, -3))],
        ),
        child: ElevatedButton(
          onPressed: () => _handlePay(provider),
          child: const Text('Pay now'),
        ),
      ),
    );
  }

  Widget _methodTile(BuildContext context,
      {required PaymentMethod method,
      required IconData icon,
      required String label,
      required PaymentMethod selected}) {
    final isSelected = method == selected;
    return GestureDetector(
      onTap: () => context.read<BookingProvider>().updatePaymentMethod(method),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryDark : AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                  )),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: bold ? 15 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: bold ? AppColors.textPrimary : AppColors.textSecondary)),
        Text(value,
            style: TextStyle(
                fontSize: bold ? 16 : 14,
                fontWeight: FontWeight.w700,
                color: bold ? AppColors.primaryDark : AppColors.textPrimary)),
      ],
    );
  }
}

/// Auto-inserts a "/" after MM as the user types, turning raw digits
/// (e.g. "0828") into "08/28".
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (text.length == 2 && oldValue.text.length == 1) {
      text = '$text/';
    }
    if (text.length > 2 && !text.contains('/')) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
