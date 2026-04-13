// lib/core/utils/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../services/supabase_service.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/members/presentation/pages/members_page.dart';
import '../../features/events/presentation/pages/events_page.dart';
import '../../features/hackathons/presentation/pages/hackathons_page.dart';
import '../../features/learn/presentation/pages/learn_page.dart';
import '../../features/quiz/presentation/pages/quiz_page.dart';
import '../../features/ai_mentor/presentation/pages/ai_mentor_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/leaderboard/presentation/pages/leaderboard_page.dart';
import '../../features/announcements/presentation/pages/announcements_page.dart';
import '../../features/resources/presentation/pages/resources_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../shared/widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.routeLogin,
    redirect: (context, state) {
      final isLoggedIn = SupabaseService.currentUser != null;
      final isOnAuth = state.matchedLocation == AppConstants.routeLogin;
      if (!isLoggedIn && !isOnAuth) return AppConstants.routeLogin;
      if (isLoggedIn && isOnAuth) return AppConstants.routeHome;
      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (_, __) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppConstants.routeHome,
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: AppConstants.routeMembers,
            builder: (_, __) => const MembersPage(),
          ),
          GoRoute(
            path: AppConstants.routeEvents,
            builder: (_, __) => const EventsPage(),
          ),
          GoRoute(
            path: AppConstants.routeHackathons,
            builder: (_, __) => const HackathonsPage(),
          ),
          GoRoute(
            path: AppConstants.routeLearn,
            builder: (_, __) => const LearnPage(),
          ),
          GoRoute(
            path: AppConstants.routeQuiz,
            builder: (_, __) => const QuizPage(),
          ),
          GoRoute(
            path: AppConstants.routeAiMentor,
            builder: (_, __) => const AiMentorPage(),
          ),
          GoRoute(
            path: AppConstants.routeProjects,
            builder: (_, __) => const ProjectsPage(),
          ),
          GoRoute(
            path: AppConstants.routeLeaderboard,
            builder: (_, __) => const LeaderboardPage(),
          ),
          GoRoute(
            path: AppConstants.routeAnnouncements,
            builder: (_, __) => const AnnouncementsPage(),
          ),
          GoRoute(
            path: AppConstants.routeResources,
            builder: (_, __) => const ResourcesPage(),
          ),
          GoRoute(
            path: AppConstants.routeProfile,
            builder: (_, __) => const ProfilePage(),
          ),
          GoRoute(
            path: AppConstants.routeSettings,
            builder: (_, __) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});
