import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/doodle_decorations.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _stats;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await _apiClient.dio.get('/users/me/stats');
      if (mounted) {
        setState(() {
          _stats = response.data['data'] as Map<String, dynamic>;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final isGuest = user?.accountStatus == 'GUEST';

        final gamesPlayed = _stats?['gamesPlayed'] ?? 48;
        final gamesWon = _stats?['gamesWon'] ?? 29;
        final winRate = gamesPlayed > 0 ? ((gamesWon / gamesPlayed) * 100).toInt() : 0;
        final totalScore = _stats?['totalScore'] ?? 1840;

        return Scaffold(
          backgroundColor: AppColors.bgRoot,
          appBar: AppBar(
            backgroundColor: AppColors.bgRoot,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Artist Studio',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: AmbientDoodleBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header Card
                    GlassCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          AvatarWidget(
                            avatarUrl: user?.avatarUrl,
                            displayName: user?.displayName ?? 'Artist',
                            radius: 40,
                            showBorder: true,
                            borderColor: AppColors.primaryCoral,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user?.displayName ?? 'Guest Artist',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${user?.username ?? "guest"}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isGuest
                                  ? AppColors.surfaceContainerHigh
                                  : AppColors.accentMint.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isGuest ? 'Guest Pass Session' : 'Verified Doodler',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isGuest ? AppColors.textSecondary : AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Career Stats Bento
                    Text(
                      'Career Record',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatBox('Played', '$gamesPlayed', Icons.sports_esports, AppColors.textSecondary),
                        const SizedBox(width: 8),
                        _buildStatBox('Wins', '$gamesWon', Icons.emoji_events, AppColors.accentMint),
                        const SizedBox(width: 8),
                        _buildStatBox('Win %', '$winRate%', Icons.trending_up, AppColors.secondary),
                        const SizedBox(width: 8),
                        _buildStatBox('Pts', '$totalScore', Icons.local_fire_department, AppColors.primaryCoral),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Audio & Accessibility Settings Card
                    Text(
                      'Game Settings',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GlassCard(
                      borderRadius: 22,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.volume_up, size: 20, color: AppColors.primaryCoral),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Sound Effects',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Switch.adaptive(
                                value: _soundEnabled,
                                activeTrackColor: AppColors.accentMint,
                                onChanged: (v) => setState(() => _soundEnabled = v),
                              ),
                            ],
                          ),
                          const Divider(height: 20, color: AppColors.borderSubtle),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.vibration, size: 20, color: AppColors.secondary),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Haptic Vibrations',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Switch.adaptive(
                                value: _hapticsEnabled,
                                activeTrackColor: AppColors.accentMint,
                                onChanged: (v) => setState(() => _hapticsEnabled = v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Logout Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.errorContainer),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.logout, size: 18),
                      label: Text(
                        'Sign Out of Session',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                        context.go('/welcome');
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
