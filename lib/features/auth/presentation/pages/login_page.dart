// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../data/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLogin = true;
  final _nameCtrl = TextEditingController();
  final _uniCtrl = TextEditingController(text: 'FAST — Université de Parakou');
  final _fieldCtrl = TextEditingController(text: 'Licence Mathématiques Fondamentales');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _nameCtrl.dispose();
    _uniCtrl.dispose();
    _fieldCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    if (_isLogin) {
      await notifier.signIn(
        email: _emailCtrl.text.trim(),
        password: _pwCtrl.text.trim(),
      );
    } else {
      await notifier.signUp(
        email: _emailCtrl.text.trim(),
        password: _pwCtrl.text.trim(),
        fullName: _nameCtrl.text.trim(),
        university: _uniCtrl.text.trim(),
        field: _fieldCtrl.text.trim(),
      );
    }
    final state = ref.read(authNotifierProvider);
    state.whenOrNull(
      data: (user) {
        if (user != null && mounted) context.go(AppConstants.routeHome);
      },
      error: (e, _) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.roseLight, AppColors.rose],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('DM',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(AppConstants.appName,
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.roseDark,
                        )),
                    const SizedBox(height: 4),
                    Text(AppConstants.appTagline,
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center),
                  ],
                ),
                const SizedBox(height: 32),

                // Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isLogin ? 'Connexion' : 'Créer un compte',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLogin
                                ? 'Bon retour parmi nous !'
                                : 'Rejoins la communauté DevMa',
                            style: AppTextStyles.bodyMuted,
                          ),
                          const SizedBox(height: 20),

                          // Name (register only)
                          if (!_isLogin) ...[
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nom complet',
                                prefixIcon: Icon(Icons.person_outline, size: 18),
                              ),
                              validator: (v) => v!.isEmpty ? 'Requis' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _uniCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Université',
                                prefixIcon: Icon(Icons.school_outlined, size: 18),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _fieldCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Filière / Spécialité',
                                prefixIcon: Icon(Icons.book_outlined, size: 18),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined, size: 18),
                            ),
                            validator: (v) =>
                                v!.contains('@') ? null : 'Email invalide',
                          ),
                          const SizedBox(height: 12),

                          // Password
                          TextFormField(
                            controller: _pwCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: const Icon(Icons.lock_outline, size: 18),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 18,
                                ),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => v!.length < 6
                                ? 'Minimum 6 caractères'
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // Submit
                          ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_isLogin ? 'Se connecter' : 'Créer mon compte'),
                          ),
                          const SizedBox(height: 14),

                          // Toggle
                          TextButton(
                            onPressed: () => setState(() => _isLogin = !_isLogin),
                            child: Text(
                              _isLogin
                                  ? 'Pas encore membre ? Rejoindre DevMa'
                                  : 'Déjà un compte ? Se connecter',
                              style: TextStyle(
                                color: AppColors.roseDark,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
