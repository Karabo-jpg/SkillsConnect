import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillconnect/injection_container.dart' as di;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillconnect/presentation/pages/home_page.dart';
import 'package:skillconnect/presentation/pages/login_page.dart';
import 'package:skillconnect/presentation/blocs/auth_bloc.dart';
import 'package:skillconnect/presentation/blocs/settings/settings_bloc.dart';
import 'package:skillconnect/presentation/blocs/settings/settings_event.dart';
import 'package:skillconnect/presentation/blocs/settings/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  await di.init();
  runApp(const SkillConnectApp());
}

final sl = di.sl;

class SkillConnectApp extends StatelessWidget {
  const SkillConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => sl<SettingsBloc>()..add(LoadSettings()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SkillConnect',
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFE67E22), // Deep Orange
                primary: const Color(0xFFE67E22),
                secondary: const Color(0xFF16A085), // Professional Teal
                surface: const Color(0xFFFFF9F0), // Soft Cream
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.outfitTextTheme(
                ThemeData.light().textTheme,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFE67E22),
                brightness: Brightness.dark,
              ),
              textTheme: GoogleFonts.outfitTextTheme(
                ThemeData.dark().textTheme,
              ),
            ),
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is Authenticated) {
                  return const HomePage();
                } else if (authState is Unauthenticated) {
                  return const LoginPage();
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
