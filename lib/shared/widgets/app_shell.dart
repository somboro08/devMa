// lib/shared/widgets/app_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}

const _navSections = [
  {
    'title': 'Principal',
    'items': [
      _NavItem('Accueil', Icons.home_outlined, AppConstants.routeHome),
      _NavItem('Membres', Icons.group_outlined, AppConstants.routeMembers),
      _NavItem('Événements', Icons.event_outlined, AppConstants.routeEvents),
      _NavItem('Hackathons', Icons.emoji_events_outlined, AppConstants.routeHackathons),
    ],
  },
  {
    'title': 'Apprentissage',
    'items': [
      _NavItem('Cours & Modules', Icons.menu_book_outlined, AppConstants.routeLearn),
      _NavItem('Quiz & Défis', Icons.quiz_outlined, AppConstants.routeQuiz),
      _NavItem('IA Mentor', Icons.smart_toy_outlined, AppConstants.routeAiMentor),
    ],
  },
  {
    'title': 'Communauté',
    'items': [
      _NavItem('Projets', Icons.rocket_launch_outlined, AppConstants.routeProjects),
      _NavItem('Classement', Icons.leaderboard_outlined, AppConstants.routeLeaderboard),
      _NavItem('Annonces', Icons.campaign_outlined, AppConstants.routeAnnouncements),
      _NavItem('Ressources', Icons.link_outlined, AppConstants.routeResources),
    ],
  },
  {
    'title': 'Compte',
    'items': [
      _NavItem('Mon Profil', Icons.person_outline, AppConstants.routeProfile),
      _NavItem('Paramètres', Icons.settings_outlined, AppConstants.routeSettings),
    ],
  },
];

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _sidebarOpen = false;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;
    final location = GoRouterState.of(context).matchedLocation;

    final sidebar = _Sidebar(currentRoute: location);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isWide ? null : Drawer(child: sidebar),
      body: Row(
        children: [
          // Desktop sidebar
          if (isWide) sidebar,
          // Content
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  onMenuTap: isWide
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  currentRoute: location,
                ),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String currentRoute;
  const _Sidebar({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.gray200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.roseLight)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DevMa',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.roseDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Développement & Sciences',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          // Nav
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final section in _navSections) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        section['title'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.rose,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    for (final item in section['items'] as List<_NavItem>)
                      _NavTile(item: item, isActive: currentRoute == item.route),
                  ],
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                _MiniAvatar(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KOROGONE S.',
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                      Text('Initiateur', style: AppTextStyles.caption),
                    ],
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

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  const _NavTile({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(item.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? AppColors.rosePale : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? AppColors.rose : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 17,
              color: isActive ? AppColors.roseDark : AppColors.gray500,
            ),
            const SizedBox(width: 10),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                color: isActive ? AppColors.roseDark : AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final String currentRoute;
  const _TopBar({this.onMenuTap, required this.currentRoute});

  String get _title {
    const map = {
      AppConstants.routeHome: 'Accueil',
      AppConstants.routeMembers: 'Membres',
      AppConstants.routeEvents: 'Événements',
      AppConstants.routeHackathons: 'Hackathons',
      AppConstants.routeLearn: 'Cours & Modules',
      AppConstants.routeQuiz: 'Quiz & Défis',
      AppConstants.routeAiMentor: 'IA Mentor',
      AppConstants.routeProjects: 'Projets',
      AppConstants.routeLeaderboard: 'Classement',
      AppConstants.routeAnnouncements: 'Annonces',
      AppConstants.routeResources: 'Ressources',
      AppConstants.routeProfile: 'Mon Profil',
      AppConstants.routeSettings: 'Paramètres',
    };
    return map[currentRoute] ?? 'DevMa';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          if (onMenuTap != null) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuTap,
              iconSize: 20,
            ),
            const SizedBox(width: 4),
          ],
          Text(_title, style: AppTextStyles.heading3),
          const Spacer(),
          // Search
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: AppColors.gray400),
                const SizedBox(width: 6),
                SizedBox(
                  width: 150,
                  child: TextField(
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Rechercher...',
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.gray400),
                      fillColor: Colors.transparent,
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 20),
                onPressed: () {},
                color: AppColors.gray600,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.rose,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.roseLight, AppColors.rose],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('KS',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}
