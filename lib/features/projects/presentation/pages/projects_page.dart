// lib/features/projects/presentation/pages/projects_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/theme/app_theme.dart';

final _projectsProvider = FutureProvider((ref) => SupabaseService.getProjects());

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(_projectsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Projets DevMa', style: AppTextStyles.heading2)),
          ElevatedButton.icon(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Soumettre'),
          ),
        ]),
        const SizedBox(height: 16),
        projects.when(
          data: (list) => list.isEmpty
              ? const Center(child: Text('Aucun projet pour le moment'))
              : LayoutBuilder(builder: (ctx, c) {
                  final cols = c.maxWidth > 700 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols, crossAxisSpacing: 12,
                      mainAxisSpacing: 12, childAspectRatio: 1.1,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _ProjectCard(list[i]),
                  );
                }),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e', style: const TextStyle(color: AppColors.error)),
        ),
      ]),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final stackCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouveau projet'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Titre du projet')),
          const SizedBox(height: 10),
          TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 10),
          TextField(controller: stackCtrl, decoration: const InputDecoration(labelText: 'Stack (ex: Flutter, Python)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty) {
                await SupabaseService.createProject({
                  'title': titleCtrl.text,
                  'description': descCtrl.text,
                  'stack': stackCtrl.text.split(',').map((s) => s.trim()).toList(),
                  'status': 'Idée',
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Soumettre'),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Map<String, dynamic> p;
  const _ProjectCard(this.p);

  Color get _statusColor {
    switch (p['status']) {
      case 'En cours': return AppColors.rose;
      case 'Terminé': return AppColors.success;
      default: return AppColors.gray400;
    }
  }

  Color get _statusBg {
    switch (p['status']) {
      case 'En cours': return AppColors.rosePale;
      case 'Terminé': return AppColors.successLight;
      default: return AppColors.gray100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stack = (p['stack'] as List?)?.cast<String>() ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p['emoji'] ?? '🚀', style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        Text(p['title'] ?? '', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(p['description'] ?? '', style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
        const Spacer(),
        Wrap(spacing: 4, runSpacing: 4, children: stack.map((s) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(4)),
          child: Text(s, style: const TextStyle(fontSize: 10, color: AppColors.info)),
        )).toList()),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(20)),
          child: Text(p['status'] ?? 'Idée', style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}
