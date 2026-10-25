import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/doodle_decorations.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../rooms/data/room_repository.dart';
import '../../../rooms/domain/room_member_model.dart';
import '../bloc/waiting_lobby_bloc.dart';

class WaitingLobbyScreen extends StatelessWidget {
  final String roomId;

  const WaitingLobbyScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.select<AuthBloc, String>((bloc) {
      final s = bloc.state;
      return s is AuthAuthenticated ? s.user.id : '';
    });

    return BlocProvider(
      create: (context) => WaitingLobbyBloc(
        roomRepository: RoomRepository(),
      )..add(LobbyLoadRequested(roomId, currentUserId)),
      child: const _WaitingLobbyView(),
    );
  }
}

class _WaitingLobbyView extends StatefulWidget {
  const _WaitingLobbyView();

  @override
  State<_WaitingLobbyView> createState() => _WaitingLobbyViewState();
}

class _WaitingLobbyViewState extends State<_WaitingLobbyView> {
  bool _copied = false;

  void _copyRoomCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room code copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WaitingLobbyBloc, WaitingLobbyState>(
      listener: (context, state) {
        if (state is WaitingLobbyGameStarting) {
          // Transition directly to game screen!
          context.go('/game/${state.roomId}');
        } else if (state is WaitingLobbyLeft) {
          context.go('/home');
        } else if (state is WaitingLobbyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is WaitingLobbyLoading) {
          return const Scaffold(
            backgroundColor: AppColors.bgRoot,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryCoral),
            ),
          );
        }

        if (state is WaitingLobbyLoaded) {
          final room = state.room;
          final isHost = state.isHost;
          final isReady = state.isReady;
          final readyCount = room.members.where((m) => m.isReady).length;
          final canStart = state.canStart;

          return Scaffold(
            backgroundColor: AppColors.bgRoot,
            body: Stack(
              children: [
                const AmbientDoodleBackground(),

                // Scrollable Content
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 70, bottom: 130),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Room Code Card (Stylized letter boxes)
                        _buildRoomCodeCard(room.roomCode),
                        const SizedBox(height: 16),

                        // Game Settings Pill Strip
                        _buildSettingsStrip(room.totalRounds, room.drawTimeSeconds, room.difficulty, room.category),
                        const SizedBox(height: 20),

                        // Player Roster Header
                        _buildRosterHeader(readyCount, room.members.length, room.maxPlayers),
                        const SizedBox(height: 12),

                        // 2-Column Player Grid (up to maxPlayers slots)
                        _buildPlayerGrid(room.members, room.maxPlayers, state.currentUserId, isHost, isReady),
                        const SizedBox(height: 18),

                        // Host Settings Quick Panel
                        if (isHost) _buildHostSettingsPanel(),
                      ],
                    ),
                  ),
                ),

                // Top Header (Live Match)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildTopHeader(),
                ),

                // Bottom Sticky Action Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomActionBar(isHost, isReady, canStart, readyCount, room.members.length),
                ),
              ],
            ),
          );
        }

        return const Scaffold(
          backgroundColor: AppColors.bgRoot,
          body: Center(child: Text('Loading lobby...')),
        );
      },
    );
  }

  // --- Top Header ---
  Widget _buildTopHeader() {
    return GlassCard(
      borderRadius: 0,
      opacity: 0.88,
      blur: 16,
      border: Border(
        bottom: BorderSide(color: AppColors.borderSubtle),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () {
                      context.read<WaitingLobbyBloc>().add(LobbyLeaveRoom());
                    },
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.draw, color: AppColors.primaryCoral, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Live Match',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final user = state is AuthAuthenticated ? state.user : null;
                  return AvatarWidget(
                    avatarUrl: user?.avatarUrl,
                    displayName: user?.displayName ?? 'Player',
                    radius: 17,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Room Code Card ---
  Widget _buildRoomCodeCard(String code) {
    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.meeting_room, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'PARTY DUEL CODE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stylized Boxes
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: code.split('').map((char) {
                final isDash = char == '-';
                if (isDash) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '-',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                }
                return Container(
                  width: 34,
                  height: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      char,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryCoral,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons: Copy & Share
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLow,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(
                    _copied ? Icons.check : Icons.content_copy,
                    size: 16,
                    color: AppColors.primaryCoral,
                  ),
                  label: Text(
                    _copied ? 'Copied!' : 'Copy Code',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => _copyRoomCode(code),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLow,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.share, size: 16, color: AppColors.accentMint),
                  label: Text(
                    'Share Link',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => _copyRoomCode(code),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Settings Pill Strip ---
  Widget _buildSettingsStrip(int rounds, int drawTime, String difficulty, String category) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPill(Icons.replay, '$rounds Rounds', AppColors.primaryCoral),
          const SizedBox(width: 8),
          _buildPill(Icons.timer, '${drawTime}s Turn', AppColors.accentMint),
          const SizedBox(width: 8),
          _buildPill(Icons.tune, difficulty, AppColors.tertiary),
          const SizedBox(width: 8),
          _buildPill(Icons.category, category, AppColors.accentLavender),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push('/sketchpad'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primaryCoral.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.palette, size: 14, color: AppColors.primaryCoral),
                  const SizedBox(width: 6),
                  Text(
                    'Practice Doodle 🎨',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryCoral,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(IconData icon, String text, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // --- Roster Header ---
  Widget _buildRosterHeader(int readyCount, int currentPlayers, int maxPlayers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Easel Arena',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$readyCount / $currentPlayers Ready',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        Text(
          'Need 2 to start',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // --- 2-Column Player Grid ---
  Widget _buildPlayerGrid(
    List<RoomMemberModel> members,
    int maxPlayers,
    String currentUserId,
    bool isHost,
    bool isReady,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: maxPlayers,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        if (index < members.length) {
          final m = members[index];
          final isCurrentUser = m.userId == currentUserId;

          return GlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(10),
            border: isCurrentUser
                ? Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.4), width: 1.5)
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AvatarWidget(
                          avatarUrl: m.avatarUrl,
                          displayName: m.displayName,
                          radius: 17,
                        ),
                        if (m.isHost)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: AppColors.accentYellow,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text('👑', style: TextStyle(fontSize: 10)),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (isCurrentUser)
                      GestureDetector(
                        onTap: () {
                          context.read<WaitingLobbyBloc>().add(LobbyToggleReady());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isReady ? AppColors.secondaryContainer : AppColors.primaryCoral,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isReady ? Icons.check_circle : Icons.check,
                                size: 12,
                                color: isReady ? AppColors.secondary : Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isReady ? 'Ready!' : 'Ready Up',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isReady ? AppColors.secondary : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: m.isReady
                              ? AppColors.secondaryContainer.withValues(alpha: 0.5)
                              : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          m.isReady ? 'Ready' : 'Waiting',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: m.isReady ? AppColors.secondary : AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCurrentUser ? 'You (${m.displayName})' : m.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      m.isHost ? 'Party Host' : 'Doodle Artist',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: m.isHost ? AppColors.primaryCoral : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          // Empty Slot
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add, color: AppColors.primaryCoral, size: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Slot ${index + 1}',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                  ),
                  Text(
                    '+ Invite',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryCoral,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  // --- Host Settings Panel ---
  Widget _buildHostSettingsPanel() {
    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.security, size: 18, color: AppColors.primaryCoral),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room Access',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Invite Only with code',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.accentMint,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Bottom Action Bar ---
  Widget _buildBottomActionBar(
    bool isHost,
    bool isReady,
    bool canStart,
    int readyCount,
    int totalCount,
  ) {
    return GlassCard(
      borderRadius: 0,
      opacity: 0.92,
      blur: 20,
      border: Border(
        top: BorderSide(color: AppColors.borderSubtle),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isHost)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canStart ? AppColors.primaryCoral : AppColors.surfaceContainerHigh,
                    foregroundColor: canStart ? Colors.white : AppColors.textMuted,
                    elevation: canStart ? 4 : 0,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: canStart
                      ? () {
                          context.read<WaitingLobbyBloc>().add(LobbyStartGame());
                        }
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.palette, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        canStart
                            ? 'Start Match ($readyCount/$totalCount Ready)'
                            : 'Need at least 2 players',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryCoral,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Waiting for Host to start ($readyCount/$totalCount Ready)...',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              // Leave Lobby
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  minimumSize: const Size(double.infinity, 38),
                ),
                icon: const Icon(Icons.logout, size: 16),
                label: Text(
                  'Leave Lobby',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  context.read<WaitingLobbyBloc>().add(LobbyLeaveRoom());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
