// lib/features/settings/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/theme/app_theme.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _geminiCtrl = TextEditingController();
  bool _notifEvents = true;
  bool _notifCourses = true;
  bool _notifMessages = false;
  bool _notifNewsletter = true;
  bool _obscureGemini = true;

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Paramètres', style: AppTextStyles.heading2),
          const SizedBox(height: 20),

          // Account info
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Compte', style: AppTextStyles.heading3),
              const SizedBox(height: 14),
              _Field(label: 'Nom complet', initial: user?.userMetadata?['full_name'] ?? ''),
              const SizedBox(height: 10),
              _Field(label: 'Email', initial: user?.email ?? '', readOnly: true),
              const SizedBox(height: 10),
              _Field(label: 'Université', initial: user?.userMetadata?['university'] ?? ''),
              const SizedBox(height: 10),
              _Field(label: 'Filière', initial: user?.userMetadata?['field'] ?? ''),
              const SizedBox(height: 14),
              ElevatedButton(onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil mis à jour !'), backgroundColor: AppColors.success));
              }, child: const Text('Enregistrer les modifications')),
            ]),
          )),
          const SizedBox(height: 14),

          // Gemini API
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('🤖 Clé API Gemini', style: AppTextStyles.heading3),
              const SizedBox(height: 4),
              Text('Nécessaire pour le module IA Mentor', style: AppTextStyles.bodyMuted),
              const SizedBox(height: 12),
              TextField(
                controller: _geminiCtrl,
                obscureText: _obscureGemini,
                decoration: InputDecoration(
                  labelText: 'Clé API Gemini (AIza...)',
                  hintText: 'AIzaSy...',
                  prefixIcon: const Icon(Icons.key_outlined, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureGemini ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                    onPressed: () => setState(() => _obscureGemini = !_obscureGemini),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(8)),
                child: Row(children: const [
                  Icon(Icons.info_outline, size: 16, color: AppColors.info),
                  SizedBox(width: 8),
                  Expanded(child: Text(
                    'Obtiens ta clé gratuite sur aistudio.google.com/apikey',
                    style: TextStyle(fontSize: 12, color: AppColors.info),
                  )),
                ]),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: save to secure storage
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Clé API Gemini enregistrée !'), backgroundColor: AppColors.success));
                },
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Connecter l\'IA'),
              ),
            ]),
          )),
          const SizedBox(height: 14),

          // Notifications
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Notifications', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              _Toggle('Événements à venir', _notifEvents, (v) => setState(() => _notifEvents = v)),
              _Toggle('Nouveaux cours', _notifCourses, (v) => setState(() => _notifCourses = v)),
              _Toggle('Messages privés', _notifMessages, (v) => setState(() => _notifMessages = v)),
              _Toggle('Newsletter DevMa', _notifNewsletter, (v) => setState(() => _notifNewsletter = v)),
            ]),
          )),
          const SizedBox(height: 14),

          // Logout
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Session', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await SupabaseService.signOut();
                  if (context.mounted) context.go(AppConstants.routeLogin);
                },
                icon: const Icon(Icons.logout, size: 16, color: AppColors.error),
                label: const Text('Se déconnecter', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
              ),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label, initial;
  final bool readOnly;
  const _Field({required this.label, required this.initial, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: readOnly ? AppColors.gray100 : AppColors.white,
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: AppTextStyles.body)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.rose,
        ),
      ]),
    );
  }
}
