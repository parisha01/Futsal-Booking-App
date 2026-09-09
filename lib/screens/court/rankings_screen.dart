import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/court.dart';
import 'court_details_screen.dart';

/// Ranks all courts by user rating, highest first — the "futsal details
/// and rankings" feature. Top 3 get a medal-style badge to make the
/// leaderboard feel more like the competitive-league features seen in
/// apps like KheloMore/Playo.
class RankingsScreen extends StatelessWidget {
  const RankingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ranked = [...CourtRepository.courts]..sort((a, b) => b.rating.compareTo(a.rating));

    return Scaffold(
      appBar: AppBar(title: const Text('Court Rankings')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: ranked.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final court = ranked[i];
            final rank = i + 1;
            return GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CourtDetailsScreen(court: court)),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    _rankBadge(rank),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Image.network(
                        court.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 56, height: 56, color: AppColors.primaryLight,
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
                          const SizedBox(height: 2),
                          Text(court.location,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: AppColors.accent),
                        const SizedBox(width: 2),
                        Text('${court.rating}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _rankBadge(int rank) {
    Color color;
    switch (rank) {
      case 1:
        color = const Color(0xFFFFD700); // gold
        break;
      case 2:
        color = const Color(0xFFC0C0C0); // silver
        break;
      case 3:
        color = const Color(0xFFCD7F32); // bronze
        break;
      default:
        color = AppColors.border;
    }
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text('$rank',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: rank <= 3 ? Colors.white : AppColors.textSecondary,
            )),
      ),
    );
  }
}
