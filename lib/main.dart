import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vsign_mobile_app/core/network/api_client.dart';
import 'package:vsign_mobile_app/core/router/app_router.dart';
import 'package:vsign_mobile_app/core/theme/season_themes.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  getIt.registerSingleton<ApiClient>(ApiClient());
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit()..setSeasonFromDate(),
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
