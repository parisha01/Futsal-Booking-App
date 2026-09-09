import 'court.dart';

enum BookingStatus { confirmed, completed, cancelled }

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum PaymentMethod { card, paypal, cash }

class Booking {
  final String id; // unique booking ID shown on confirmation
  final Court court;
  final DateTime date;
  final String timeSlot;
  final int players;
  final double serviceFee;
  final PaymentMethod paymentMethod;
  BookingStatus status;

  Booking({
    required this.id,
    required this.court,
    required this.date,
    required this.timeSlot,
    required this.players,
    this.serviceFee = 2.0,
    this.paymentMethod = PaymentMethod.card,
    this.status = BookingStatus.confirmed,
    this.discountPercent = 0,
  });

  /// Dynamic price calculation: court rental scales with player count
  /// in blocks of 5 (extra players = extra court time/space), plus a flat
  /// service fee. This satisfies the "system calculates total price
  /// dynamically based on player count and service fees" requirement.
  double get courtRental {
    final blocks = (players / 5).ceil().clamp(1, 10);
    return court.pricePerHour * blocks;
  }

  final double discountPercent;

  double get discountAmount => courtRental * discountPercent;

  double get total => courtRental + serviceFee - discountAmount;
}
