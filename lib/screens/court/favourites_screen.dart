import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/court.dart';
import '../../providers/user_provider.dart';
import '../../widgets/court_card.dart';
import 'court_details_screen.dart';
import '../booking/booking_screen.dart';

/// Shows courts the user has favourited (heart icon on Court List/Card
/// and Court Details), so they can find preferred venues quickly later.
class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final favourites = CourtRepository.courts
        .where((c) => user.isFavorite(c.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Favourites')),
      body: SafeArea(
        child: favourites.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text('No favourites yet', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Tap the heart icon on a court to save it here.',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: favourites
                    .map((c) => CourtCard(
                          court: c,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: c)),
                          ),
                          onBookNow: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => BookingScreen(court: c)),
                          ),
                        ))
                    .toList(),
              ),
      ),
    );
  }
}
