// lib/features/learn/presentation/pages/learn_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/theme/app_theme.dart';

final _coursesProvider = FutureProvider((ref) => SupabaseService.getCourses());

class LearnPage extends ConsumerWidget {
  const LearnPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(_coursesProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Cours & Modules', style: AppTextStyles.heading2),
        const SizedBox(height: 16),
        courses.when(
          data: (list) => list.isEmpty
              ? const _Placeholder('📚', 'Aucun cours disponible', 'Les cours seront ajoutés prochainement.')
              : LayoutBuilder(builder: (ctx, c) {
                  final cols = c.maxWidth > 700 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _CourseCard(list[i]),
                  );
                }),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
        ),
      ]),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> c;
  const _CourseCard(this.c);
  @override
  Widget build(BuildContext context) {
    final progress = (c['progress'] as int?) ?? 0;
    return Container(
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gray200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c['icon'] ?? '📚', style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(c['title'] ?? '', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(c['description'] ?? '', style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
        const Spacer(),
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$progress%', style: AppTextStyles.caption),
            Chip(label: Text(c['level'] ?? 'Débutant'), backgroundColor: AppColors.rosePale, labelStyle: const TextStyle(fontSize: 10, color: AppColors.roseDark), padding: EdgeInsets.zero),
          ]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: AppColors.gray200,
            color: AppColors.rose,
            minHeight: 4,
          )),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8), textStyle: const TextStyle(fontSize: 12)),
            child: Text(progress > 0 ? 'Continuer' : 'Commencer'),
          )),
        ])),
      ]),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String icon, title, subtitle;
  const _Placeholder(this.icon, this.title, this.subtitle);
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(32), alignment: Alignment.center, child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 40)),
      const SizedBox(height: 12),
      Text(title, style: AppTextStyles.heading3),
      const SizedBox(height: 4),
      Text(subtitle, style: AppTextStyles.bodyMuted, textAlign: TextAlign.center),
    ]));
  }
}
