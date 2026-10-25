import 'package:go_router/go_router.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/gameplay/drawing/warmup_sketchpad_screen.dart';
import '../features/gameplay/presentation/game_container_screen.dart';
import '../features/home/presentation/screens/home_lobby_screen.dart';
import '../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../features/lobby/presentation/screens/waiting_lobby_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/rooms/presentation/screens/create_room_screen.dart';
import '../features/rooms/presentation/screens/discover_rooms_screen.dart';
import '../features/rooms/presentation/screens/join_room_screen.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // If user is authenticated and attempts to visit welcome/login/register, redirect to /home
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      // If unauthenticated and trying to access protected game routes, redirect to /welcome
      if (!isAuthenticated && !isAuthRoute) {
        return '/welcome';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeLobbyScreen(),
      ),
      GoRoute(
        path: '/create-room',
        builder: (context, state) => const CreateRoomScreen(),
      ),
      GoRoute(
        path: '/join-room',
        builder: (context, state) => const JoinRoomScreen(),
      ),
      GoRoute(
        path: '/discover',
        builder: (context, state) => const DiscoverRoomsScreen(),
      ),
      GoRoute(
        path: '/lobby/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? '';
          return WaitingLobbyScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/game/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? '';
          return GameContainerScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/sketchpad',
        builder: (context, state) => const WarmupSketchpadScreen(),
      ),
    ],
  );
}
