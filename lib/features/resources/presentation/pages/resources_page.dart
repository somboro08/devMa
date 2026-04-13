// lib/features/resources/presentation/pages/resources_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/theme/app_theme.dart';

final _resourcesProvider = FutureProvider((ref) => SupabaseService.getResources());

// Fallback static resources if DB is empty
const _staticResources = [
  {'category': '🐍 Python', 'title': 'Documentation officielle Python', 'url': 'https://docs.python.org/fr/3/'},
  {'category': '🐍 Python', 'title': 'Real Python — Tutoriels pratiques', 'url': 'https://realpython.com'},
  {'category': '📱 Flutter', 'title': 'Flutter.dev — Docs officielles', 'url': 'https://flutter.dev'},
  {'category': '📱 Flutter', 'title': 'pub.dev — Packages Flutter', 'url': 'https://pub.dev'},
  {'category': '🗄️ Supabase', 'title': 'Supabase Documentation', 'url': 'https://supabase.com/docs'},
  {'category': '🌐 Web', 'title': 'MDN Web Docs', 'url': 'https://developer.mozilla.org/fr/'},
  {'category': '🌐 Web', 'title': 'FastAPI Documentation', 'url': 'https://fastapi.tiangolo.com'},
  {'category': '🎨 Design', 'title': 'Figma Community', 'url': 'https://www.figma.com/community'},
  {'category': '📊 Data & IA', 'title': 'Kaggle Datasets & Notebooks', 'url': 'https://www.kaggle.com'},
  {'category': '📊 Data & IA', 'title': 'Google AI Studio', 'url': 'https://aistudio.google.com'},
  {'category': '🔧 DevOps', 'title': 'Git Documentation', 'url': 'https://git-scm.com/doc'},
  {'category': '🔧 DevOps', 'title': 'GitHub Student Pack', 'url': 'https://education.github.com/pack'},
];

class ResourcesPage extends ConsumerWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_resourcesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Ressources', style: AppTextStyles.heading2)),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Ajouter'),
          ),
        ]),
        const SizedBox(height: 16),
        data.when(
          data: (list) {
            final resources = list.isNotEmpty
                ? list
                : _staticResources.map((r) => Map<String, dynamic>.from(r)).toList();

            // Group by category
            final Map<String, List<Map<String, dynamic>>> grouped = {};
            for (final r in resources) {
              final cat = r['category'] as String? ?? 'Autres';
              grouped.putIfAbsent(cat, () => []).add(r);
            }

            return LayoutBuilder(builder: (ctx, c) {
              final cols = c.maxWidth > 700 ? 2 : 1;
              final cats = grouped.entries.toList();
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols, crossAxisSpacing: 14,
                  mainAxisSpacing: 14, childAspectRatio: 1.6,
                ),
                itemCount: cats.length,
                itemBuilder: (_, i) {
                  final cat = cats[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(cat.key, style: AppTextStyles.heading3),
                      const SizedBox(height: 10),
                      ...cat.value.map((r) => InkWell(
                        onTap: () async {
                          final url = Uri.parse(r['url'] ?? '');
                          if (await canLaunchUrl(url)) await launchUrl(url);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(children: [
                            const Icon(Icons.link, size: 14, color: AppColors.rose),
                            const SizedBox(width: 6),
                            Expanded(child: Text(
                              r['title'] ?? '',
                              style: const TextStyle(fontSize: 13, color: AppColors.rose),
                              overflow: TextOverflow.ellipsis,
                            )),
                          ]),
                        ),
                      )),
                    ]),
                  );
                },
              );
            });
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e', style: const TextStyle(color: AppColors.error)),
        ),
      ]),
    );
  }
}
