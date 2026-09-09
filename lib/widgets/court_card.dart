import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/court.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';

class CourtCard extends StatelessWidget {
  final Court court;
  final VoidCallback onTap;
  final VoidCallback onBookNow;

  const CourtCard({
    super.key,
    required this.court,
    required this.onTap,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<UserProvider>().isFavorite(court.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      court.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(color: AppColors.primaryLight);
                      },
                      errorBuilder: (context, error, stack) => Container(
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.sports_soccer, color: AppColors.primary, size: 40),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => context.read<UserProvider>().toggleFavorite(court.id),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorite ? AppColors.danger : AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(court.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: AppColors.accent),
                      const SizedBox(width: 2),
                      Text('${court.rating}', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      Text('•', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      Text(
                        '\$${court.pricePerHour.toStringAsFixed(0)}/hr',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: onBookNow,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Text('Book now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
