import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/rooms/data/room_repository.dart';
import 'features/rooms/presentation/bloc/room_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepository = AuthRepository();
  final roomRepository = RoomRepository();
  final authBloc = AuthBloc(authRepository: authRepository)..add(AuthCheckRequested());

  runApp(
    DoodleDuelApp(
      authBloc: authBloc,
      roomRepository: roomRepository,
    ),
  );
}

class DoodleDuelApp extends StatefulWidget {
  final AuthBloc authBloc;
  final RoomRepository roomRepository;

  const DoodleDuelApp({
    super.key,
    required this.authBloc,
    required this.roomRepository,
  });

  @override
  State<DoodleDuelApp> createState() => _DoodleDuelAppState();
}

class _DoodleDuelAppState extends State<DoodleDuelApp> {
  late final router = createRouter(widget.authBloc);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authBloc),
        BlocProvider(create: (_) => RoomBloc(roomRepository: widget.roomRepository)),
      ],
      child: MaterialApp.router(
        title: 'Doodle Duel',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.warmGlassTheme,
        routerConfig: router,
      ),
    );
  }
}
