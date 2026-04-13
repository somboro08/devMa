// lib/features/ai_mentor/presentation/pages/ai_mentor_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/theme/app_theme.dart';

class _Message {
  final String role; // 'user' | 'ai'
  final String content;
  final DateTime time;
  _Message({required this.role, required this.content}) : time = DateTime.now();
}

final _messagesProvider =
    StateNotifierProvider<_MessagesNotifier, List<_Message>>(
  (ref) => _MessagesNotifier(),
);

class _MessagesNotifier extends StateNotifier<List<_Message>> {
  _MessagesNotifier()
      : super([
          _Message(
            role: 'ai',
            content:
                'Salut ! 👋 Je suis le **Mentor IA de DevMa**, propulsé par Gemini.\n\nJe peux t\'aider à :\n- 🐍 Apprendre Python, Dart, JavaScript...\n- 🔧 Corriger et améliorer ton code\n- 🎯 Préparer tes hackathons\n- 📚 Comprendre les maths et l\'informatique\n\nPar où commences-tu ?',
          )
        ]);

  bool _loading = false;
  bool get isLoading => _loading;

  Future<void> send(String message) async {
    state = [...state, _Message(role: 'user', content: message)];
    _loading = true;

    try {
      final response = await GeminiService.sendMessage(message);
      state = [...state, _Message(role: 'ai', content: response)];
    } catch (e) {
      state = [
        ...state,
        _Message(
          role: 'ai',
          content:
              '❌ Erreur de connexion à l\'IA. Vérifie ta clé API Gemini dans les paramètres.\n\n`$e`',
        ),
      ];
    }
    _loading = false;
  }
}

final _loadingProvider = StateProvider<bool>((ref) => false);

class AiMentorPage extends ConsumerStatefulWidget {
  const AiMentorPage({super.key});

  @override
  ConsumerState<AiMentorPage> createState() => _AiMentorPageState();
}

class _AiMentorPageState extends ConsumerState<AiMentorPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  final _suggestions = [
    'Explique les listes Python',
    'Qu\'est-ce qu\'une API REST?',
    'Comment utiliser Supabase?',
    'Corrige ce code : print("hello")',
    'Conseils pour un hackathon',
    'Différence SQL vs NoSQL',
    'Introduis Flutter en 2 minutes',
    'Qu\'est-ce que l\'IA?',
  ];

  Future<void> _send([String? text]) async {
    final msg = (text ?? _ctrl.text).trim();
    if (msg.isEmpty || _sending) return;
    _ctrl.clear();
    setState(() => _sending = true);

    await ref.read(_messagesProvider.notifier).send(msg);

    setState(() => _sending = false);
    await Future.delayed(const Duration(milliseconds: 100));
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(_messagesProvider);
    final isWide = MediaQuery.of(context).size.width >= 768;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _ChatPanel(messages, _sending, _ctrl, _scroll, _send)),
                const SizedBox(width: 16),
                SizedBox(width: 260, child: _SidePanel(_suggestions, _send)),
              ],
            )
          : Column(children: [
              _SidePanel(_suggestions, _send, compact: true),
              const SizedBox(height: 12),
              Expanded(child: _ChatPanel(messages, _sending, _ctrl, _scroll, _send)),
            ]),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  final List<_Message> messages;
  final bool sending;
  final TextEditingController ctrl;
  final ScrollController scroll;
  final Future<void> Function([String?]) onSend;
  const _ChatPanel(this.messages, this.sending, this.ctrl, this.scroll, this.onSend);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.rosePale,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mentor IA DevMa',
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    Row(children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                            color: AppColors.success, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text('En ligne · Gemini 1.5 Flash',
                          style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                    ]),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: 'Effacer la conversation',
                  onPressed: () => GeminiService.clearHistory(),
                  color: AppColors.gray500,
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (sending ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (sending && i == messages.length) {
                  return const _TypingBubble();
                }
                return _MessageBubble(messages[i]);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Pose ta question...',
                      filled: true,
                      fillColor: AppColors.gray100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: sending ? null : () => onSend(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    minimumSize: Size.zero,
                  ),
                  child: sending
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Message message;
  const _MessageBubble(this.message);

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.rosePale,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.rose : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isUser ? 12 : 2),
                  bottomRight: Radius.circular(isUser ? 2 : 12),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.gray200),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 13,
                  color: isUser ? Colors.white : AppColors.gray700,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.roseLight, AppColors.rose],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('KS',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 600))
        ..repeat(reverse: true),
    );
    _anims = _controllers.map((c) => c.drive(CurveTween(curve: Curves.easeInOut))).toList();
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: AppColors.rosePale,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => AnimatedBuilder(
              animation: _anims[i],
              builder: (_, __) => Padding(
                padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                child: Transform.translate(
                  offset: Offset(0, -4 * _anims[i].value),
                  child: Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.roseLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            )),
          ),
        ),
      ],
    );
  }
}

class _SidePanel extends StatelessWidget {
  final List<String> suggestions;
  final Future<void> Function(String) onSend;
  final bool compact;
  const _SidePanel(this.suggestions, this.onSend, {this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sujets suggérés', style: AppTextStyles.heading3),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: suggestions.map((s) => ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    onPressed: () => onSend(s),
                    backgroundColor: AppColors.rosePale,
                    side: const BorderSide(color: AppColors.roseLight),
                    labelStyle: const TextStyle(color: AppColors.roseDark),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mode spécial', style: AppTextStyles.heading3),
                  const SizedBox(height: 10),
                  _ModeButton('🔍 Révision de code', 'Corrige et améliore mon code :', onSend),
                  const SizedBox(height: 6),
                  _ModeButton('🎯 Conseils hackathon', 'Donne-moi des conseils pour préparer un hackathon de 24h sur le thème :', onSend),
                  const SizedBox(height: 6),
                  _ModeButton('📚 Explique un concept', 'Explique-moi ce concept de façon simple :', onSend),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final String prompt;
  final Future<void> Function(String) onSend;
  const _ModeButton(this.label, this.prompt, this.onSend);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => onSend(prompt),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        minimumSize: const Size(double.infinity, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
