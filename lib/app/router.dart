import 'package:go_router/go_router.dart';

import '../features/auth/account_created_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/welcome_screen.dart';
import '../features/home/home_screen.dart';

import '../features/choose_option/choose_option_screen.dart';
import '../features/upload_photo/upload_photo_screen.dart';
import '../features/select_mood/select_mood_screen.dart';
import '../features/result/result_screen.dart';

import '../features/analyzing/analyzing_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/account-created',
      builder: (context, state) => const AccountCreatedScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/choose-option', builder: (c, s) => const ChooseOptionScreen()),
    GoRoute(path: '/upload-photo', builder: (c, s) => const UploadPhotoScreen()),
    GoRoute(path: '/select-mood', builder: (c, s) => const SelectMoodScreen()),
    GoRoute(path: '/result', builder: (c, s) => ResultScreen(args: s.extra as ResultArgs?),),
    GoRoute(path: '/analyzing', builder: (c, s) => AnalyzingScreen(imagePath: s.extra as String),),
  ],
);
