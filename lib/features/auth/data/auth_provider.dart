// lib/features/auth/data/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return SupabaseService.currentUser;
});

// Auth state stream
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.authStateChanges;
});

// Profile provider
final profileProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, userId) async {
    return SupabaseService.getProfile(userId);
  },
);

// Auth notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.data(null)) {
    _init();
  }

  void _init() {
    final user = SupabaseService.currentUser;
    state = AsyncValue.data(user);

    SupabaseService.authStateChanges.listen((event) {
      state = AsyncValue.data(event.session?.user);
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );
      state = AsyncValue.data(response.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? university,
    String? field,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        university: university,
        field: field,
      );
      state = AsyncValue.data(response.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>(
  (ref) => AuthNotifier(),
);
