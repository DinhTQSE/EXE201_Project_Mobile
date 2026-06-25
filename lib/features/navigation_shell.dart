import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vsign_mobile_app/features/auth/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize Auth state check
    context.read<AuthBloc>().add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final Widget child;
  const MainNavigationShell({required this.child, super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/courses')) return 0;
    if (location.startsWith('/dictionary')) return 1;
    if (location.startsWith('/leaderboard')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/courses');
        break;
      case 1:
        context.go('/dictionary');
        break;
      case 2:
        context.go('/leaderboard');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.bookOpen),
            label: 'Khóa học',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.search),
            label: 'Từ điển',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.trophy),
            label: 'Xếp hạng',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
