import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum _NotifType { booking, promo, system }

class _AppNotification {
  final _NotifType type;
  final String title;
  final String subtitle;
  final String time;
  final bool unread;

  const _AppNotification({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    this.unread = false,
  });
}

/// Notifications feed covering booking confirmations/reminders and
/// promotional discounts — the "notify about offers/discounts" feature
/// requested, modelled after real booking apps' promo/pass systems
/// (e.g. KheloMore's "Discounts & Passes").
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _notifications = [
    _AppNotification(
      type: _NotifType.promo,
      title: '20% off weekend bookings',
      subtitle: 'Use code WEEKEND15 on any court this Sat-Sun. Ends midnight Sunday.',
      time: '2h ago',
      unread: true,
    ),
    _AppNotification(
      type: _NotifType.booking,
      title: 'Booking confirmed',
      subtitle: 'Kathmandu Futsal Arena • Today, 7:00pm. See you on the pitch!',
      time: '5h ago',
      unread: true,
    ),
    _AppNotification(
      type: _NotifType.promo,
      title: 'New: FUTSAL10 promo code',
      subtitle: 'Get 10% off your next booking at any venue. No minimum spend.',
      time: '1d ago',
    ),
    _AppNotification(
      type: _NotifType.system,
      title: 'Rate your last game',
      subtitle: 'How was Riverside Futsal Hub? Leave a quick review for other players.',
      time: '3d ago',
    ),
    _AppNotification(
      type: _NotifType.booking,
      title: 'Booking reminder',
      subtitle: 'Your game at Greenfield Sports Zone is tomorrow at 7:00pm.',
      time: '4d ago',
    ),
  ];

  IconData _iconFor(_NotifType type) {
    switch (type) {
      case _NotifType.booking:
        return Icons.event_available_rounded;
      case _NotifType.promo:
        return Icons.local_offer_rounded;
      case _NotifType.system:
        return Icons.info_rounded;
    }
  }

  Color _colorFor(_NotifType type) {
    switch (type) {
      case _NotifType.booking:
        return AppColors.primary;
      case _NotifType.promo:
        return AppColors.accent;
      case _NotifType.system:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: _notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final n = _notifications[i];
            final color = _colorFor(n.type);
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: n.unread ? AppColors.primaryLight : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.subtle,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_iconFor(n.type), color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(n.title, style: Theme.of(context).textTheme.titleMedium),
                            ),
                            Text(n.time, style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(n.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
