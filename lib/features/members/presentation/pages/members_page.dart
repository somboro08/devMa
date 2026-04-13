// lib/features/members/presentation/pages/members_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/theme/app_theme.dart';

final _membersProvider = FutureProvider((ref) => SupabaseService.getAllMembers());

class MembersPage extends ConsumerWidget {
  const MembersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(_membersProvider);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Membres DevMa',
                    style: AppTextStyles.heading2),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Inviter'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: members.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(child: Text('Aucun membre trouvé'));
                }
                return LayoutBuilder(builder: (ctx, c) {
                  final cols = c.maxWidth > 700 ? 3 : c.maxWidth > 400 ? 2 : 1;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _MemberCard(list[i]),
                  );
                });
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.error))),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> m;
  const _MemberCard(this.m);

  String get _initials {
    final name = (m['full_name'] ?? '') as String;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.roseLight, AppColors.rose],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(_initials,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          Text(m['full_name'] ?? '',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2),
          const SizedBox(height: 2),
          Text(m['role'] ?? 'Membre',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          if (m['points'] != null)
            Chip(
              label: Text('${m['points']} pts'),
              backgroundColor: AppColors.rosePale,
              labelStyle: const TextStyle(fontSize: 11, color: AppColors.roseDark),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
