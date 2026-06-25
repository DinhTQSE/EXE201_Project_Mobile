import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vsign_mobile_app/core/network/api_client.dart';
import 'package:vsign_mobile_app/core/network/analytics_service.dart';
import 'package:vsign_mobile_app/core/network/repositories.dart';
import 'package:vsign_mobile_app/core/router/app_router.dart';
import 'package:vsign_mobile_app/core/theme/season_themes.dart';
import 'package:vsign_mobile_app/features/auth/bloc/auth_bloc.dart';
import 'package:vsign_mobile_app/features/course/bloc/course_bloc.dart';
import 'package:vsign_mobile_app/features/dictionary/bloc/dictionary_bloc.dart';
import 'package:vsign_mobile_app/features/gamification/bloc/gamification_bloc.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<AnalyticsService>(AnalyticsService());
  getIt.registerSingleton<AuthRepository>(AuthRepository());
  getIt.registerSingleton<LearningRepository>(LearningRepository());
  getIt.registerSingleton<DictionaryRepository>(DictionaryRepository());
  getIt.registerSingleton<GamificationRepository>(GamificationRepository());
  getIt.registerSingleton<PaymentRepository>(PaymentRepository());
}

// BLoC for Managing Seasonal Themes
class ThemeCubit extends Cubit<SeasonThemeMode> {
  ThemeCubit() : super(SeasonThemeMode.spring);

  void changeTheme(SeasonThemeMode mode) => emit(mode);

  void setSeasonFromDate() {
    final month = DateTime.now().month;
    // Map months to Vietnam's typical seasons:
    // Spring: 2, 3, 4
    // Summer: 5, 6, 7
    // Fall: 8, 9, 10
    // Winter: 11, 12, 1
    if (month >= 2 && month <= 4) {
      emit(SeasonThemeMode.spring);
    } else if (month >= 5 && month <= 7) {
      emit(SeasonThemeMode.summer);
    } else if (month >= 8 && month <= 10) {
      emit(SeasonThemeMode.fall);
    } else {
      emit(SeasonThemeMode.winter);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  setupDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit()..setSeasonFromDate(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<CourseBloc>(
          create: (context) => CourseBloc(),
        ),
        BlocProvider<DictionaryBloc>(
          create: (context) => DictionaryBloc(),
        ),
        BlocProvider<GamificationBloc>(
          create: (context) => GamificationBloc(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, SeasonThemeMode>(
        builder: (context, mode) {
          return MaterialApp.router(
            title: 'V-Sign Mobile',
            debugShowCheckedModeBanner: false,
            theme: SeasonThemes.getTheme(mode),
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
