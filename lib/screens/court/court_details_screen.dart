import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/court.dart';
import '../../providers/user_provider.dart';
import '../booking/booking_screen.dart';

class CourtDetailsScreen extends StatefulWidget {
  final Court court;
  const CourtDetailsScreen({super.key, required this.court});

  @override
  State<CourtDetailsScreen> createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends State<CourtDetailsScreen> {
  String? _hoveredSlot;

  IconData _amenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'parking':
        return Icons.local_parking_rounded;
      case 'floodlights':
        return Icons.wb_incandescent_rounded;
      case 'changing rooms':
        return Icons.checkroom_rounded;
      case 'water station':
        return Icons.water_drop_rounded;
      case 'covered roof':
        return Icons.roofing_rounded;
      case 'showers':
        return Icons.shower_rounded;
      case 'cafe on-site':
        return Icons.local_cafe_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final court = widget.court;
    final isFavorite = context.watch<UserProvider>().isFavorite(court.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Court details'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.danger : AppColors.textSecondary,
            ),
            onPressed: () => context.read<UserProvider>().toggleFavorite(court.id),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    court.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.sports_soccer, size: 48, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(court.name, style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      Text('\$${court.pricePerHour.toStringAsFixed(0)}/hr',
                          style: const TextStyle(
                            color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 18,
                          )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text('${court.rating} rating', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 10),
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(court.location,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(court.description, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 22),
                  if (court.amenities.isNotEmpty) ...[
                    Text('Amenities', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: court.amenities.map((a) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_amenityIcon(a), size: 14, color: AppColors.primaryDark),
                            const SizedBox(width: 6),
                            Text(a, style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                          ],
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 16),
                  Text('Available time slots', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: court.availableSlots.map((slot) {
                      final selected = _hoveredSlot == slot;
                      return GestureDetector(
                        onTap: () => setState(() => _hoveredSlot = slot),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                                color: selected ? AppColors.primary : AppColors.border),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: selected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reviews (${court.reviews.length})',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Text('See all reviews',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...court.reviews.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            boxShadow: AppShadows.subtle,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(r.reviewerName, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < r.rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                                        size: 14,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(r.comment, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      )),
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
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookingScreen(court: court, preselectedSlot: _hoveredSlot),
            ),
          ),
          child: const Text('Book now'),
        ),
      ),
    );
  }
}
