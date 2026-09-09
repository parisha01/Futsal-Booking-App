# Futsal Booking App — Flutter Front-End (Assessment 4)

Cross-platform front-end implementation of the Futsal Booking App, based on
the high-fidelity Figma prototype from Assessment 3.

## Implemented major features

1. **Full Booking Flow** — Court List (search + filter by price/time/location
   + sort) → Court Details (photos, rating, amenities, reviews, time slots)
   → Booking (date/time/player selection with live dynamic price calculation,
   **double-booking prevention**, **promo code** discount) → Payment
   (method selection + validated card fields + order summary) →
   Confirmation (booking ID, manage booking link).
2. **My Bookings** — Upcoming/Past tabs, Booking Details, Cancel (live
   status update via Provider).
3. **Account system** — Sign Up (name, mobile number, email, password +
   confirm password, full validation) registers a real account; Login
   validates against it and shows specific errors ("no account found" vs
   "incorrect email or password"); Profile shows account info with Edit
   Profile and Delete my account; Remember me checkbox on Login.
4. **Favourites** — heart icon on every court card and Court Details;
   My Favourites screen lists saved venues.
5. **Rankings** — courts ranked by rating with medal badges for top 3.
6. **Compare venues** — select 2-3 courts on Court List to see a
   side-by-side comparison highlighting the top-rated pick.
7. **Notifications** — booking confirmations, reminders, and discount
   promos.

7 courts total (3 Nepal-based from the original prototype + 4 Australian
venues: Sydney, Melbourne, Gold Coast, Perth), each with full details,
amenities, and reviews.

## Notable design decisions

- **Real credential validation**: `UserProvider` keeps an in-memory
  email→password/name/phone map. Sign Up registers; Login checks the
  email exists and the password matches, returning a specific error
  otherwise — not just accepting any input.
- **Double-booking prevention**: `BookingProvider.isSlotTaken()` checks
  existing confirmed bookings for the same court/date/slot. A same-day
  mock booking (Kathmandu Futsal Arena, today, 7:00pm) is seeded so this
  can be demonstrated live.
- **Promo codes**: `FUTSAL10` (10% off) and `WEEKEND15` (15% off).
- These patterns (real-time slot availability, promo codes, amenities,
  rankings, favourites, venue comparison, notifications) were informed by
  reviewing comparable apps (KheloMore, Playo, Book Playgrounds).

## Getting started

```bash
flutter pub get
flutter run
```

Requires Flutter SDK (stable channel) and a running emulator/device. If this
is a fresh checkout without platform folders, run `flutter create .` first
to generate them (this will not overwrite `lib/` or `pubspec.yaml`).

## Project structure

```
lib/
  main.dart                  # App entry point, Provider setup
  theme/app_theme.dart        # Design system: colors, typography, shadows
  models/                     # Court, Booking data models (mock data)
  providers/                  # BookingProvider, UserProvider (state management)
  screens/                    # All screens, grouped by feature
  widgets/                    # Reusable components (CourtCard, StatusBadge, nav)
```

## Notes

- This is a front-end-only implementation (no backend/API); all data is
  mocked locally via `CourtRepository`, `BookingProvider`, and `UserProvider`.
- State management uses the `provider` package throughout.
- Colors, spacing, and shadows are centralised in `app_theme.dart` to keep
  visual design consistent across all screens, matching the Figma
  prototype's green/turf identity.

# Futsal-Booking-App
