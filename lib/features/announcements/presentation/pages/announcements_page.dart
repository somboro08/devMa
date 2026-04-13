// lib/features/announcements/presentation/pages/announcements_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/theme/app_theme.dart';

final _announcementsProvider = FutureProvider((ref) => SupabaseService.getAnnouncements());

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_announcementsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Annonces', style: AppTextStyles.heading2)),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Publier'),
          ),
        ]),
        const SizedBox(height: 16),
        data.when(
          data: (list) => list.isEmpty
              ? const Center(child: Text('Aucune annonce'))
              : Column(children: list.map((a) => _AnnounceCard(a)).toList()),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e', style: const TextStyle(color: AppColors.error)),
        ),
      ]),
    );
  }
}

class _AnnounceCard extends StatelessWidget {
  final Map<String, dynamic> a;
  const _AnnounceCard(this.a);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.rosePale,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.roseLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (a['tag'] != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.rose.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(a['tag'], style: const TextStyle(fontSize: 11, color: AppColors.roseDark, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 8),
        ],
        Text(a['title'] ?? '', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.roseDark)),
        const SizedBox(height: 6),
        Text(a['content'] ?? '', style: AppTextStyles.bodyMuted),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.gray400),
          const SizedBox(width: 4),
          Text(
            a['created_at'] != null
                ? _fmt(DateTime.tryParse(a['created_at'] as String))
                : '',
            style: AppTextStyles.caption,
          ),
          if (a['profiles'] != null) ...[
            const SizedBox(width: 12),
            const Icon(Icons.person_outline, size: 12, color: AppColors.gray400),
            const SizedBox(width: 4),
            Text(a['profiles']['full_name'] ?? '', style: AppTextStyles.caption),
          ],
        ]),
      ]),
    );
  }

  String _fmt(DateTime? d) {
    if (d == null) return '';
    const months = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
