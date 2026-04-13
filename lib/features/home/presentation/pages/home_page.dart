// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/widgets/section_header.dart';

final _eventsProvider = FutureProvider((ref) => SupabaseService.getEvents());
final _announcementsProvider = FutureProvider((ref) => SupabaseService.getAnnouncements());
final _membersCountProvider = FutureProvider((ref) async {
  final m = await SupabaseService.getAllMembers();
  return m.length;
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = SupabaseService.currentUser;
    final events = ref.watch(_eventsProvider);
    final announcements = ref.watch(_announcementsProvider);
    final membersCount = ref.watch(_membersCountProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.rosePale, AppColors.white],
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.roseLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('👋 Bonjour !',
                    style: TextStyle(fontSize: 12, color: AppColors.rose, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  'Bienvenue${user?.userMetadata?['full_name'] != null ? ', ${user!.userMetadata!['full_name']}' : ''} !',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 4),
                Text(
                  'DevMa grandit chaque jour — continuons à apprendre et créer ensemble.',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.go(AppConstants.routeLearn),
                      icon: const Icon(Icons.menu_book, size: 16),
                      label: const Text('Reprendre l\'apprentissage'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go(AppConstants.routeEvents),
                      icon: const Icon(Icons.event, size: 16),
                      label: const Text('Voir les événements'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats
          LayoutBuilder(builder: (ctx, c) {
            final n = c.maxWidth > 600 ? 4 : 2;
            return GridView.count(
              crossAxisCount: n,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                membersCount.when(
                  data: (v) => StatCard(icon: '👥', label: 'Membres', value: '$v'),
                  loading: () => const StatCard(icon: '👥', label: 'Membres', value: '...'),
                  error: (_, __) => const StatCard(icon: '👥', label: 'Membres', value: '-'),
                ),
                events.when(
                  data: (v) => StatCard(icon: '📅', label: 'Événements', value: '${v.length}'),
                  loading: () => const StatCard(icon: '📅', label: 'Événements', value: '...'),
                  error: (_, __) => const StatCard(icon: '📅', label: 'Événements', value: '-'),
                ),
                const StatCard(icon: '📚', label: 'Cours', value: '18', sub: '5 nouveaux'),
                const StatCard(icon: '🚀', label: 'Projets actifs', value: '7'),
              ],
            );
          }),

          const SizedBox(height: 24),

          // Events + Announcements
          LayoutBuilder(builder: (ctx, c) {
            final isWide = c.maxWidth > 600;
            final eventsWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Prochains événements',
                  actionLabel: 'Voir tout',
                  onAction: () => context.go(AppConstants.routeEvents),
                ),
                events.when(
                  data: (list) => list.isEmpty
                      ? const _EmptyState('Aucun événement à venir')
                      : Column(
                          children: list.take(3).map((e) => _EventRow(e)).toList(),
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _EmptyState('Erreur : $e'),
                ),
              ],
            );

            final announcementsWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Dernières annonces',
                  actionLabel: 'Voir tout',
                  onAction: () => context.go(AppConstants.routeAnnouncements),
                ),
                announcements.when(
                  data: (list) => list.isEmpty
                      ? const _EmptyState('Aucune annonce')
                      : Column(
                          children: list.take(3).map((a) => _AnnounceRow(a)).toList(),
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _EmptyState('Erreur : $e'),
                ),
              ],
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: eventsWidget),
                  const SizedBox(width: 16),
                  Expanded(child: announcementsWidget),
                ],
              );
            }
            return Column(children: [eventsWidget, const SizedBox(height: 20), announcementsWidget]);
          }),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final Map<String, dynamic> event;
  const _EventRow(this.event);

  @override
  Widget build(BuildContext context) {
    final date = event['date'] != null
        ? DateTime.tryParse(event['date'] as String)
        : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.rosePale,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  date != null ? '${date.day}' : '-',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.roseDark),
                ),
                Text(
                  date != null ? _month(date.month) : '',
                  style: const TextStyle(fontSize: 10, color: AppColors.gray500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event['title'] ?? '', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                Text(event['location'] ?? '', style: AppTextStyles.caption),
              ],
            ),
          ),
          Chip(
            label: const Text('À venir'),
            backgroundColor: AppColors.rosePale,
            labelStyle: const TextStyle(fontSize: 10, color: AppColors.roseDark),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  String _month(int m) {
    const months = ['JAN','FÉV','MAR','AVR','MAI','JUN','JUL','AOÛ','SEP','OCT','NOV','DÉC'];
    return m >= 1 && m <= 12 ? months[m - 1] : '';
  }
}

class _AnnounceRow extends StatelessWidget {
  final Map<String, dynamic> a;
  const _AnnounceRow(this.a);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.rosePale,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.roseLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(a['title'] ?? '', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.roseDark)),
          const SizedBox(height: 4),
          Text(
            a['content'] ?? '',
            style: AppTextStyles.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String msg;
  const _EmptyState(this.msg);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Text(msg, style: AppTextStyles.bodyMuted),
    );
  }
}
