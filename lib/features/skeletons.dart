import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Chào mừng đến với V-Sign',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => context.go('/courses'),
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: const Center(child: Text('Trang Đăng ký')),
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
            label: 'Bảng xếp hạng',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('V-Sign - Khóa Học')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Bài học 1: Chào hỏi'),
              subtitle: const Text('Học cách chào hỏi cơ bản'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => context.push('/lesson/lesson-greetings-1'),
            ),
          ),
        ],
      ),
    );
  }
}

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Từ điển Ký hiệu')),
      body: const Center(child: Text('Tra cứu Từ điển')),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bảng Xếp Hạng')),
      body: const Center(child: Text('Xếp Hạng Học Viên')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ Cá nhân')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/login'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Đăng xuất'),
        ),
      ),
    );
  }
}

class LessonDetailScreen extends StatelessWidget {
  final String lessonId;
  const LessonDetailScreen({required this.lessonId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bài học: $lessonId')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.push('/camera-practice/practice-greetings'),
          child: const Text('Luyện tập qua Camera AI'),
        ),
      ),
    );
  }
}

class CameraPracticeScreen extends StatelessWidget {
  final String itemId;
  const CameraPracticeScreen({required this.itemId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera AI Luyện tập')),
      body: const Center(child: Text('Kích hoạt Camera và MediaPipe')),
    );
  }
}
