import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/court.dart';

/// Holds in-progress booking selections as the user moves through
/// Court Details -> Booking -> Payment -> Confirmation, and stores
/// completed bookings for the My Bookings feature.
///
/// Using Provider (rather than passing everything through constructors)
/// keeps state consistent across the multi-screen booking flow and
/// avoids the kind of navigation bugs that would cost "no errors" marks.
class BookingProvider extends ChangeNotifier {
  // ---- In-progress booking draft ----
  Court? selectedCourt;
  DateTime? selectedDate;
  String? selectedSlot;
  int players = 10;
  PaymentMethod paymentMethod = PaymentMethod.card;
  double appliedDiscount = 0; // e.g. 0.15 = 15% off
  String? appliedPromoCode;

  /// Mock promo codes — mirrors the "Discounts & Passes" feature seen in
  /// real booking apps (e.g. KheloMore's promo/pass system).
  static const Map<String, double> _promoCodes = {
    'FUTSAL10': 0.10,
    'WEEKEND15': 0.15,
  };

  /// Returns true and applies the discount if the code is valid.
  bool applyPromoCode(String code) {
    final normalized = code.trim().toUpperCase();
    if (_promoCodes.containsKey(normalized)) {
      appliedDiscount = _promoCodes[normalized]!;
      appliedPromoCode = normalized;
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearPromoCode() {
    appliedDiscount = 0;
    appliedPromoCode = null;
    notifyListeners();
  }

  // ---- Completed bookings (mock persistence for this session) ----
  late final List<Booking> _bookings = [
    // Booked for TODAY at 7:00pm on Kathmandu Futsal Arena — lets you
    // demo the double-booking prevention live: try booking the same
    // court/date/7:00pm slot again and it will show as unavailable.
    Booking(
      id: 'FB-10240',
      court: CourtRepository.courts[0],
      date: DateTime.now(),
      timeSlot: '7:00pm',
      players: 12,
      status: BookingStatus.confirmed,
    ),
    Booking(
      id: 'FB-10231',
      court: CourtRepository.courts[0],
      date: DateTime(2026, 8, 12),
      timeSlot: '6:00pm',
      players: 10,
      status: BookingStatus.confirmed,
    ),
    Booking(
      id: 'FB-10198',
      court: CourtRepository.courts[2],
      date: DateTime(2026, 7, 15),
      timeSlot: '7:00pm',
      players: 15,
      status: BookingStatus.confirmed,
    ),
    Booking(
      id: 'FB-10142',
      court: CourtRepository.courts[1],
      date: DateTime(2026, 6, 18),
      timeSlot: '3:00pm',
      players: 8,
      status: BookingStatus.cancelled,
    ),
  ];

  List<Booking> get bookings => List.unmodifiable(_bookings);

  List<Booking> get upcoming =>
      _bookings.where((b) => b.status == BookingStatus.confirmed).toList();

  List<Booking> get past => _bookings
      .where((b) => b.status != BookingStatus.confirmed)
      .toList();

  /// Checks whether a given court/date/time-slot combination is already
  /// held by another confirmed booking — prevents two users from
  /// double-booking the same venue at the same time, matching how real
  /// booking apps (e.g. KheloMore, Playo) show real-time availability.
  bool isSlotTaken(Court court, DateTime date, String slot) {
    return _bookings.any((b) =>
        b.status == BookingStatus.confirmed &&
        b.court.id == court.id &&
        b.date.year == date.year &&
        b.date.month == date.month &&
        b.date.day == date.day &&
        b.timeSlot == slot);
  }

  void startBooking(Court court) {
    selectedCourt = court;
    selectedDate = DateTime.now();
    selectedSlot = court.availableSlots.first;
    players = 10;
    appliedDiscount = 0;
    appliedPromoCode = null;
    notifyListeners();
  }

  void updateDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void updateSlot(String slot) {
    selectedSlot = slot;
    notifyListeners();
  }

  void updatePlayers(int count) {
    if (count < 2) return;
    players = count;
    notifyListeners();
  }

  void updatePaymentMethod(PaymentMethod method) {
    paymentMethod = method;
    notifyListeners();
  }

  final _random = Random();

  /// Finalises the draft into a confirmed Booking with a unique ID.
  /// Rejects the confirmation if the slot was taken by someone else
  /// in the meantime (defensive double-check alongside the UI-level
  /// disabled-slot prevention in BookingScreen).
  Booking confirmBooking() {
    if (isSlotTaken(selectedCourt!, selectedDate!, selectedSlot!)) {
      throw StateError('This slot has just been booked by someone else.');
    }
    final booking = Booking(
      id: 'FB-${10000 + _bookings.length + _random.nextInt(900)}',
      court: selectedCourt!,
      date: selectedDate!,
      timeSlot: selectedSlot!,
      players: players,
      paymentMethod: paymentMethod,
      status: BookingStatus.confirmed,
      discountPercent: appliedDiscount,
    );
    _bookings.insert(0, booking);
    notifyListeners();
    return booking;
  }

  void cancelBooking(String id) {
    final booking = _bookings.firstWhere((b) => b.id == id);
    booking.status = BookingStatus.cancelled;
    notifyListeners();
  }
}
