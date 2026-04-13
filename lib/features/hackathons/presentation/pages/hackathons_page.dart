// lib/features/hackathons/presentation/pages/hackathons_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/theme/app_theme.dart';

final _hackathonsProvider = FutureProvider((ref) => SupabaseService.getHackathons());

class HackathonsPage extends ConsumerWidget {
  const HackathonsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_hackathonsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text('Hackathons & Challenges', style: AppTextStyles.heading2)),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Proposer'),
            ),
          ]),
          const SizedBox(height: 20),
          data.when(
            data: (list) => list.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.rosePale,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.roseLight),
                    ),
                    child: Column(children: [
                      const Text('🎯', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      Text('Aucun hackathon pour le moment', style: AppTextStyles.heading3),
                      const SizedBox(height: 4),
                      Text('Le premier hackathon DevMa arrive bientôt !', style: AppTextStyles.bodyMuted),
                    ]),
                  )
                : Column(
                    children: list.map((h) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(left: const BorderSide(color: AppColors.rose, width: 4), right: const BorderSide(color: AppColors.gray200), top: const BorderSide(color: AppColors.gray200), bottom: const BorderSide(color: AppColors.gray200)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(h['title'] ?? '', style: AppTextStyles.heading3),
                        const SizedBox(height: 4),
                        Text(h['description'] ?? '', style: AppTextStyles.bodyMuted),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: () {}, child: const Text('Participer')),
                      ]),
                    )).toList(),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
          ),
        ],
      ),
    );
  }
}
