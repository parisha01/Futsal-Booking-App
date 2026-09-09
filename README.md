# Futsal Booking App

This is the Flutter front-end for my Futsal Booking App, built for Assessment 4. It follows the high-fidelity Figma prototype I designed in Assessment 3.

## What the app does

The app lets users search for futsal courts, view details about each venue, book a time slot, pay, and manage their bookings afterwards. It also includes an account system, favourites, court rankings, and a way to compare venues side by side.

## Main features

**Booking flow**
- Browse courts with search, filters (price, time, location), and sorting
- View court details — photos, ratings, amenities, reviews, and available time slots
- Book a court by picking a date, time slot, and number of players, with the price calculated live
- Already-booked time slots are shown as unavailable so two people can't double-book the same slot
- Apply a promo code (try FUTSAL10 or WEEKEND15) for a discount
- Pay by card, PayPal, or cash, with basic validation on card details
- Get a confirmation screen with a unique booking ID

**Managing bookings**
- See upcoming and past bookings
- View booking details and cancel if needed

**Account**
- Sign up with name, mobile number, email, and password (with confirm password)
- Log in with real validation — wrong email or password shows a proper error message
- Edit your profile details, upload a profile photo from your gallery, or delete your account
- "Remember me" option on login

**Other features**
- Favourite courts and view them later in one place
- See courts ranked by rating
- Compare 2–3 courts side by side
- Notifications for bookings and promo offers

There are 7 courts in total — the 3 original ones from my Assessment 3 prototype plus 4 more based in Australia (Sydney, Melbourne, Gold Coast, and Perth).

## Why I built it this way

- Since this is front-end only, there's no real backend — all data is stored locally using Provider (BookingProvider and UserProvider) for the current session.
- I added real login/signup validation rather than letting any input through, since that felt more like a genuine app.
- I looked at a few existing booking apps (KheloMore, Playo) for ideas on things like real-time slot availability, promo codes, and venue rankings, then adapted them to fit this app.
- I put more effort into the visual design this time — consistent colours, spacing, and shadows — since that was flagged as an area to improve in my Assessment 3 feedback.

## Running the project

flutter pub get
flutter run

You'll need Flutter installed and an emulator or device running. If you're setting this up fresh and the android/ios folders are missing, run flutter create . first (this won't overwrite anything in lib/).

## Project structure

lib/
  main.dart              # App entry point
  theme/                 # Colours, typography, spacing
  models/                # Court and Booking data
  providers/             # State management (bookings, user account)
  screens/               # All the app's screens
  widgets/               # Shared components like cards and nav bar
