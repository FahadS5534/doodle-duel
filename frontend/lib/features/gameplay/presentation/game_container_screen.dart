import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../results/presentation/screens/final_results_screen.dart';
import '../../results/presentation/screens/round_results_dialog.dart';
import '../blocs/drawing_cubit.dart';
import '../blocs/game_bloc.dart';
import '../drawing/drawing_gameplay_screen.dart';
import '../guessing/guessing_gameplay_screen.dart';

class GameContainerScreen extends StatelessWidget {
  final String roomId;

  const GameContainerScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.select<AuthBloc, String>((bloc) {
      final s = bloc.state;
      return s is AuthAuthenticated ? s.user.id : '';
    });

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DrawingCubit(
            roomId: roomId,
          ),
        ),
        BlocProvider(
          create: (context) => GameBloc()
            ..add(GameInitRequested(roomId, currentUserId)),
        ),
      ],
      child: const _GameContainerView(),
    );
  }
}

class _GameContainerView extends StatelessWidget {
  const _GameContainerView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {},
      builder: (context, state) {
        // 1. If match is finished, show Final Results Screen
        if (state.phase == GamePhase.matchFinished) {
          return FinalResultsScreen(gameState: state);
        }

        // 2. Active gameplay: switch dynamically between Drawer & Guesser view
        return Stack(
          children: [
            if (state.isDrawer)
              DrawingGameplayScreen(gameState: state)
            else
              GuessingGameplayScreen(gameState: state),

            // 3. Round results overlay
            if (state.phase == GamePhase.roundResults)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: RoundResultsDialog(gameState: state),
              ),
          ],
        );
      },
    );
  }
}
