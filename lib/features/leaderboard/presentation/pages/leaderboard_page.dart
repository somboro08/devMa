// lib/features/leaderboard/presentation/pages/leaderboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/theme/app_theme.dart';

final _leaderboardProvider = FutureProvider((ref) => SupabaseService.getLeaderboard());

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_leaderboardProvider);
    final me = SupabaseService.currentUser?.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Classement', style: AppTextStyles.heading2),
        const SizedBox(height: 4),
        Text('Top membres du mois', style: AppTextStyles.bodyMuted),
        const SizedBox(height: 20),
        data.when(
          data: (list) => LayoutBuilder(builder: (ctx, c) {
            final isWide = c.maxWidth > 600;
            final rankList = Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('🏆 Top membres', style: AppTextStyles.heading3),
                  const SizedBox(height: 12),
                  ...list.asMap().entries.map((entry) {
                    final i = entry.key;
                    final m = entry.value;
                    final isMe = m['id'] == me;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.rosePale : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        _RankBadge(i + 1),
                        const SizedBox(width: 12),
                        Container(
                          width: 32, height: 32,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.roseLight, AppColors.rose]),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text(
                            _initials(m['full_name'] ?? ''),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          )),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(
                          m['full_name'] ?? '',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
                            color: isMe ? AppColors.roseDark : AppColors.gray700,
                          ),
                        )),
                        Text(
                          '${m['points'] ?? 0} pts',
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: isMe ? AppColors.roseDark : AppColors.rose,
                          ),
                        ),
                      ]),
                    );
                  }),
                ]),
              ),
            );

            final myCard = Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Ta position', style: AppTextStyles.heading3),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.rosePale,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(children: [
                      Text(
                        '#${list.indexWhere((m) => m['id'] == me) + 1}',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.roseDark),
                      ),
                      Text('sur ${list.length} membres', style: AppTextStyles.bodyMuted),
                      const SizedBox(height: 8),
                      Text(
                        '${list.firstWhere((m) => m['id'] == me, orElse: () => {'points': 0})['points']} pts',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.rose),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Text('Comment gagner des points', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  ...[
                    ['Terminer un cours', '+50 pts'],
                    ['Réussir un quiz', '+20 pts'],
                    ['Gagner un hackathon', '+500 pts'],
                    ['Soumettre un projet', '+100 pts'],
                    ['Présence événement', '+30 pts'],
                  ].map((row) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      Expanded(child: Text(row[0], style: AppTextStyles.body)),
                      Text(row[1], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.rose)),
                    ]),
                  )),
                ]),
              ),
            );

            if (isWide) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 3, child: rankList),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: myCard),
              ]);
            }
            return Column(children: [rankList, const SizedBox(height: 16), myCard]);
          }),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e', style: const TextStyle(color: AppColors.error)),
        ),
      ]),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge(this.rank);

  @override
  Widget build(BuildContext context) {
    Color bg; Color fg;
    String label;
    if (rank == 1) { bg = const Color(0xFFFEF3C7); fg = const Color(0xFF92400E); label = '🥇'; }
    else if (rank == 2) { bg = AppColors.gray100; fg = AppColors.gray600; label = '🥈'; }
    else if (rank == 3) { bg = const Color(0xFFFEF3C7); fg = const Color(0xFF78350F); label = '🥉'; }
    else { bg = AppColors.rosePale; fg = AppColors.roseDark; label = '$rank'; }

    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(child: Text(label, style: TextStyle(fontSize: rank <= 3 ? 14 : 12, color: fg, fontWeight: FontWeight.w700))),
    );
  }
}
