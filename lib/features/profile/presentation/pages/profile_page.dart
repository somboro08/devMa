// lib/features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/theme/app_theme.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = SupabaseService.currentUser;
    final meta = user?.userMetadata ?? {};
    final name = meta['full_name'] as String? ?? 'Membre DevMa';
    final university = meta['university'] as String? ?? 'FAST — Université de Parakou';
    final field = meta['field'] as String? ?? '';

    String initials() {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return name.isNotEmpty ? name[0].toUpperCase() : 'D';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Identity card
          Card(child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 70, height: 70,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.roseLight, AppColors.rose]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(initials(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white))),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: AppTextStyles.heading2),
                  Text(meta['role'] as String? ?? 'Membre', style: AppTextStyles.bodyMuted),
                  const SizedBox(height: 4),
                  const Text('🏆 Rang #3', style: TextStyle(fontSize: 12, color: AppColors.rose, fontWeight: FontWeight.w500)),
                ])),
                OutlinedButton(onPressed: () {}, child: const Text('Modifier')),
              ]),
              const Divider(height: 24),
              _InfoGrid([
                ['Université', university],
                ['Filière', field],
                ['Rôle DevMa', meta['role'] as String? ?? 'Membre'],
                ['Email', user?.email ?? ''],
              ]),
            ]),
          )),
          const SizedBox(height: 16),

          // Skills
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Compétences', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                'Python', 'FastAPI', 'Flutter', 'Dart', 'Firebase', 'Supabase', 'Git', 'Linux', 'Maths'
              ].map((s) => Chip(
                label: Text(s),
                backgroundColor: AppColors.rosePale,
                labelStyle: const TextStyle(fontSize: 12, color: AppColors.roseDark),
              )).toList()),
            ]),
          )),
          const SizedBox(height: 16),

          // Stats
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Activité', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              Row(children: [
                _StatMini('Cours terminés', '4'),
                const SizedBox(width: 12),
                _StatMini('Quiz réussis', '47'),
                const SizedBox(width: 12),
                _StatMini('Projets', '3'),
                const SizedBox(width: 12),
                _StatMini('Points', '1520'),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final List<List<String>> rows;
  const _InfoGrid(this.rows);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 4,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      children: rows.map((r) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r[0], style: AppTextStyles.label),
        Text(r[1], style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
      ])).toList(),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label, value;
  const _StatMini(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray800)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
      ]),
    ));
  }
}
