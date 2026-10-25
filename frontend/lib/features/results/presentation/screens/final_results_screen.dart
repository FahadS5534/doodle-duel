import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/coral_button.dart';
import '../../../../core/widgets/doodle_decorations.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../gameplay/blocs/game_bloc.dart';

class FinalResultsScreen extends StatelessWidget {
  final GameState gameState;

  const FinalResultsScreen({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    // Sort players by score descending
    final sortedPlayers = List<PlayerScoreEntry>.from(gameState.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    final winner = sortedPlayers.isNotEmpty ? sortedPlayers.first : null;

    return Scaffold(
      backgroundColor: AppColors.bgRoot,
      body: AmbientDoodleBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                // Match Complete Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          'MATCH FINISHED',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Winner Podium Card
                if (winner != null)
                  GlassCard(
                    borderRadius: 28,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AvatarWidget(
                              avatarUrl: winner.avatarUrl,
                              displayName: winner.displayName,
                              radius: 36,
                              showBorder: true,
                              borderColor: AppColors.accentYellow,
                            ),
                            Positioned(
                              top: -12,
                              right: -4,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentYellow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text('👑', style: TextStyle(fontSize: 16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          winner.displayName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'GRAND CHAMPION',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: AppColors.primaryCoral,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${winner.score} Points',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryCoral,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // Leaderboard Standings Card
                Text(
                  'Final Standings',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(16),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedPlayers.length,
                    separatorBuilder: (_, index) => const Divider(height: 16, color: AppColors.borderSubtle),
                    itemBuilder: (context, index) {
                      final p = sortedPlayers[index];
                      final rank = index + 1;

                      String medal = '#$rank';
                      if (rank == 1) medal = '🥇';
                      if (rank == 2) medal = '🥈';
                      if (rank == 3) medal = '🥉';

                      return Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              medal,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AvatarWidget(
                            avatarUrl: p.avatarUrl,
                            displayName: p.displayName,
                            radius: 16,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              p.displayName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '${p.score} pts',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: rank == 1 ? AppColors.primaryCoral : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Action CTAs
                CoralButton(
                  text: 'Play Again / New Match',
                  icon: const Icon(Icons.replay, color: Colors.white, size: 20),
                  onPressed: () {
                    context.go('/home');
                  },
                ),
                const SizedBox(height: 10),

                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.home, size: 18, color: AppColors.primaryCoral),
                  label: Text(
                    'Return to Home Lobby',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => context.go('/home'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
