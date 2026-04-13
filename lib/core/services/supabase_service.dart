// lib/core/services/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  // ── AUTH ──────────────────────────────────────────────────────────────────

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? university,
    String? field,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'university': university ?? 'FAST — Université de Parakou',
        'field': field ?? 'Licence Mathématiques Fondamentales',
        'role': 'member',
      },
    );
    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() => client.auth.signOut();

  static User? get currentUser => client.auth.currentUser;
  static Session? get currentSession => client.auth.currentSession;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  // ── PROFILES ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await client
        .from(AppConstants.tableProfiles)
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  static Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await client
        .from(AppConstants.tableProfiles)
        .upsert({'id': userId, ...data});
  }

  static Future<List<Map<String, dynamic>>> getAllMembers() async {
    return await client
        .from(AppConstants.tableProfiles)
        .select()
        .order('points', ascending: false);
  }

  // ── EVENTS ────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getEvents({
    bool upcoming = true,
  }) async {
    final now = DateTime.now().toIso8601String();
    final query = client.from(AppConstants.tableEvents).select();
    if (upcoming) {
      return await query.gte('date', now).order('date');
    } else {
      return await query.lt('date', now).order('date', ascending: false);
    }
  }

  static Future<void> registerForEvent({
    required String eventId,
    required String userId,
  }) async {
    await client.from(AppConstants.tableEventRegistrations).insert({
      'event_id': eventId,
      'user_id': userId,
      'registered_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<String>> getUserEventRegistrations(String userId) async {
    final data = await client
        .from(AppConstants.tableEventRegistrations)
        .select('event_id')
        .eq('user_id', userId);
    return data.map<String>((e) => e['event_id'] as String).toList();
  }

  // ── HACKATHONS ────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getHackathons() async {
    return await client
        .from(AppConstants.tableHackathons)
        .select()
        .order('start_date');
  }

  // ── COURSES ───────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getCourses() async {
    return await client
        .from(AppConstants.tableCourses)
        .select('*, course_modules(count)')
        .order('order_index');
  }

  static Future<Map<String, dynamic>?> getUserCourseProgress({
    required String userId,
    required String courseId,
  }) async {
    return await client
        .from(AppConstants.tableUserCourseProgress)
        .select()
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .maybeSingle();
  }

  static Future<void> updateCourseProgress({
    required String userId,
    required String courseId,
    required int completedModules,
    required int totalModules,
  }) async {
    final progress = (completedModules / totalModules * 100).round();
    await client.from(AppConstants.tableUserCourseProgress).upsert({
      'user_id': userId,
      'course_id': courseId,
      'completed_modules': completedModules,
      'progress_percent': progress,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ── QUIZ ──────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getQuizzes() async {
    return await client
        .from(AppConstants.tableQuizzes)
        .select('*, quiz_questions(count)')
        .order('created_at', ascending: false);
  }

  static Future<List<Map<String, dynamic>>> getQuizQuestions(
      String quizId) async {
    return await client
        .from(AppConstants.tableQuizQuestions)
        .select()
        .eq('quiz_id', quizId)
        .order('order_index');
  }

  static Future<void> saveQuizAttempt({
    required String userId,
    required String quizId,
    required int score,
    required int totalQuestions,
    required int pointsEarned,
  }) async {
    await client.from(AppConstants.tableQuizAttempts).insert({
      'user_id': userId,
      'quiz_id': quizId,
      'score': score,
      'total_questions': totalQuestions,
      'points_earned': pointsEarned,
      'completed_at': DateTime.now().toIso8601String(),
    });
    // Update user points
    await addPoints(userId: userId, points: pointsEarned);
  }

  // ── PROJECTS ──────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getProjects() async {
    return await client
        .from(AppConstants.tableProjects)
        .select('*, profiles(full_name, avatar_url)')
        .order('created_at', ascending: false);
  }

  static Future<void> createProject(Map<String, dynamic> data) async {
    await client.from(AppConstants.tableProjects).insert({
      ...data,
      'created_by': currentUser!.id,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ── ANNOUNCEMENTS ─────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    return await client
        .from(AppConstants.tableAnnouncements)
        .select('*, profiles(full_name, avatar_url)')
        .order('created_at', ascending: false);
  }

  // ── RESOURCES ─────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getResources() async {
    return await client
        .from(AppConstants.tableResources)
        .select()
        .order('category');
  }

  // ── LEADERBOARD ───────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    return await client
        .from(AppConstants.tableProfiles)
        .select('id, full_name, avatar_url, points, role')
        .order('points', ascending: false)
        .limit(50);
  }

  // ── AI CONVERSATIONS ──────────────────────────────────────────────────────

  static Future<String> createConversation(String userId) async {
    final response = await client
        .from(AppConstants.tableAiConversations)
        .insert({
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
          'title': 'Nouvelle conversation',
        })
        .select()
        .single();
    return response['id'] as String;
  }

  static Future<List<Map<String, dynamic>>> getConversations(
      String userId) async {
    return await client
        .from(AppConstants.tableAiConversations)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  static Future<List<Map<String, dynamic>>> getMessages(
      String conversationId) async {
    return await client
        .from(AppConstants.tableAiMessages)
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at');
  }

  static Future<void> saveMessage({
    required String conversationId,
    required String role,
    required String content,
  }) async {
    await client.from(AppConstants.tableAiMessages).insert({
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ── POINTS ────────────────────────────────────────────────────────────────

  static Future<void> addPoints({
    required String userId,
    required int points,
  }) async {
    await client.rpc('increment_points', params: {
      'user_id': userId,
      'points_to_add': points,
    });
  }
}
