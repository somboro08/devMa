// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'DevMa';
  static const String appTagline = 'Développement & Sciences Appliquées';
  static const String appVersion = '1.0.0';

  // Supabase — remplace par tes vraies clés
static const String supabaseUrl = 'https://awvqyuulswppyrldcdwk.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3dnF5dXVsc3dwcHlybGRjZHdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwMjM1NDEsImV4cCI6MjA5MTU5OTU0MX0.IqhgKg04yI-nOwyspeiWe89a1sEkLN-0pTwXqVGAXQM';


  // Gemini API — remplace par ta vraie clé
static const String geminiApiKey = 'AIzaSyBsaPH1sC_YcWN7oneGJW_j9H_WthRw4jI';
  static const String geminiModel = 'gemini-2.5-flash';
  static const String geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  // Tables Supabase
  static const String tableProfiles = 'profiles';
  static const String tableEvents = 'events';
  static const String tableEventRegistrations = 'event_registrations';
  static const String tableHackathons = 'hackathons';
  static const String tableHackathonTeams = 'hackathon_teams';
  static const String tableCourses = 'courses';
  static const String tableCourseModules = 'course_modules';
  static const String tableUserCourseProgress = 'user_course_progress';
  static const String tableQuizzes = 'quizzes';
  static const String tableQuizQuestions = 'quiz_questions';
  static const String tableQuizAttempts = 'quiz_attempts';
  static const String tableProjects = 'projects';
  static const String tableAnnouncements = 'announcements';
  static const String tableResources = 'resources';
  static const String tableAiConversations = 'ai_conversations';
  static const String tableAiMessages = 'ai_messages';
  static const String tableLeaderboard = 'leaderboard';

  // Routes
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeHome = '/home';
  static const String routeMembers = '/members';
  static const String routeEvents = '/events';
  static const String routeHackathons = '/hackathons';
  static const String routeLearn = '/learn';
  static const String routeQuiz = '/quiz';
  static const String routeAiMentor = '/ai-mentor';
  static const String routeProjects = '/projects';
  static const String routeLeaderboard = '/leaderboard';
  static const String routeAnnouncements = '/announcements';
  static const String routeResources = '/resources';
  static const String routeProfile = '/profile';
  static const String routeSettings = '/settings';
}
