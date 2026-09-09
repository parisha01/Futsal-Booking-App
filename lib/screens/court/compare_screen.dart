import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/court.dart';

/// Side-by-side comparison of user-selected courts, ranked by rating —
/// the "compare futsal venues by user rating" feature. Highest rated
/// selection is highlighted.
class CompareScreen extends StatelessWidget {
  final List<Court> courts;
  const CompareScreen({super.key, required this.courts});

  @override
  Widget build(BuildContext context) {
    final sorted = [...courts]..sort((a, b) => b.rating.compareTo(a.rating));
    final bestRating = sorted.isNotEmpty ? sorted.first.rating : 0;

    return Scaffold(
      appBar: AppBar(title: Text('Compare (${courts.length})')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: sorted.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final court = sorted[i];
            final isBest = court.rating == bestRating;
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
                border: isBest ? Border.all(color: AppColors.primary, width: 1.5) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Image.network(
                          court.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60, height: 60, color: AppColors.primaryLight,
                            child: const Icon(Icons.sports_soccer, color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(court.name, style: Theme.of(context).textTheme.titleMedium),
                            Text(court.location, style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      if (isBest)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: const Text('Top rated',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _statRow('Rating', '${court.rating} ★'),
                  const SizedBox(height: 8),
                  _statRow('Price', '\$${court.pricePerHour.toStringAsFixed(0)}/hr'),
                  const SizedBox(height: 8),
                  _statRow('Amenities', '${court.amenities.length}'),
                  const SizedBox(height: 8),
                  _statRow('Reviews', '${court.reviews.length}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}
