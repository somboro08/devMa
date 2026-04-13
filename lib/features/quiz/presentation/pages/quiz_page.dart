// lib/features/quiz/presentation/pages/quiz_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/theme/app_theme.dart';

final _quizzesProvider = FutureProvider((ref) => SupabaseService.getQuizzes());

class QuizPage extends ConsumerWidget {
  const QuizPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzes = ref.watch(_quizzesProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Quiz & Défis', style: AppTextStyles.heading2),
        const SizedBox(height: 16),
        quizzes.when(
          data: (list) => list.isEmpty
              ? const Center(child: Text('Aucun quiz disponible'))
              : Column(children: list.map((q) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gray200)),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(q['title'] ?? '', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      Text('${q['quiz_questions']?[0]?['count'] ?? 0} questions', style: AppTextStyles.caption),
                    ])),
                    ElevatedButton(onPressed: () {}, child: const Text('Commencer')),
                  ]),
                )).toList()),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
        ),
      ]),
    );
  }
}
