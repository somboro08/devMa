// lib/features/events/presentation/pages/events_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/section_header.dart';

final _eventsUpcoming = FutureProvider((ref) => SupabaseService.getEvents(upcoming: true));
final _eventsPast = FutureProvider((ref) => SupabaseService.getEvents(upcoming: false));

class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({super.key});
  @override
  ConsumerState<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends ConsumerState<EventsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: SectionHeader(title: 'Événements')),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Créer'),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tab,
              labelColor: AppColors.roseDark,
              unselectedLabelColor: AppColors.gray500,
              indicatorColor: AppColors.rose,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'À venir'),
                Tab(text: 'Passés'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  ref.watch(_eventsUpcoming).when(
                    data: (list) => list.isEmpty
                        ? const Center(child: Text('Aucun événement à venir', style: TextStyle(color: AppColors.gray500)))
                        : _EventGrid(list),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.error))),
                  ),
                  ref.watch(_eventsPast).when(
                    data: (list) => list.isEmpty
                        ? const Center(child: Text('Aucun événement passé', style: TextStyle(color: AppColors.gray500)))
                        : _EventGrid(list),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventGrid extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  const _EventGrid(this.events);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth > 600 ? 3 : 1;
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemCount: events.length,
        itemBuilder: (_, i) => _EventCard(events[i]),
      );
    });
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> e;
  const _EventCard(this.e);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.roseLight, AppColors.rose],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(e['emoji'] ?? '📅', style: const TextStyle(fontSize: 26)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e['title'] ?? '', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(e['location'] ?? '', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final uid = SupabaseService.currentUser?.id;
                      if (uid != null && e['id'] != null) {
                        await SupabaseService.registerForEvent(
                          eventId: e['id'],
                          userId: uid,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Inscription confirmée !'), backgroundColor: AppColors.success),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text("S'inscrire"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
