import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/glass_card.dart';
import '../blocs/game_bloc.dart';
import '../drawing/drawing_canvas.dart';

class GuessingGameplayScreen extends StatefulWidget {
  final GameState gameState;

  const GuessingGameplayScreen({super.key, required this.gameState});

  @override
  State<GuessingGameplayScreen> createState() => _GuessingGameplayScreenState();
}

class _GuessingGameplayScreenState extends State<GuessingGameplayScreen> {
  final _guessController = TextEditingController();
  final ScrollController _feedScrollController = ScrollController();

  @override
  void dispose() {
    _guessController.dispose();
    _feedScrollController.dispose();
    super.dispose();
  }

  void _submitGuess() {
    final text = _guessController.text.trim();
    if (text.isEmpty) return;

    context.read<GameBloc>().add(GameSubmitGuess(text));
    _guessController.clear();

    // Auto-scroll guess feed
    if (_feedScrollController.hasClients) {
      _feedScrollController.animateTo(
        _feedScrollController.position.maxScrollExtent + 40,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendReaction(String emoji) {
    context.read<GameBloc>().add(GameSendReaction(emoji));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent $emoji'),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;
    final timerMins = (state.remainingSeconds ~/ 60).toString();
    final timerSecs = (state.remainingSeconds % 60).toString().padLeft(2, '0');
    final isUrgent = state.remainingSeconds <= 10;

    return Scaffold(
      backgroundColor: AppColors.bgRoot,
      body: SafeArea(
        child: Column(
          children: [
            // Top Toast Bar (Speed Bonus Prompt)
            _buildToastBar(),

            // Game Status Header
            _buildStatusHeader(state, timerMins, timerSecs, isUrgent),
            const SizedBox(height: 6),

            // Live Player Score Strip
            _buildPlayerScoreStrip(state),
            const SizedBox(height: 8),

            // Shared Remote Canvas
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB49682).withValues(alpha: 0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        // Remote Canvas in Read-Only Mode (automatically connects to DrawingCubit)
                        const DrawingCanvas(isReadOnly: true),

                        // Canvas Top Badges
                        Positioned(
                          top: 10,
                          left: 10,
                          right: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.accentMint,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Live Stream',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Round ${state.currentRound}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Word Slots & Clue Banner (Letter blanks)
            _buildLetterBlanksBanner(state),
            const SizedBox(height: 8),

            // Live Guess Activity Stream
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildGuessStream(state.guessFeed),
              ),
            ),
            const SizedBox(height: 8),

            // Quick Emoji Reaction Ribbon
            _buildReactionRibbon(),
            const SizedBox(height: 8),

            // Guess Input Box + Coral Send Button
            _buildGuessInputRow(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // --- Top Toast Bar ---
  Widget _buildToastBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, size: 16, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  "You're on fire! 1st guess earns +350 pts!",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '2x Multiplier',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Game Status Header ---
  Widget _buildStatusHeader(GameState state, String timerMins, String timerSecs, bool isUrgent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'R ${state.currentRound}/${state.totalRounds}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryCoral,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '🎨 ${state.drawerName.isNotEmpty ? state.drawerName : "Artist"} is drawing...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppColors.primaryCoral
                      : AppColors.primaryCoral.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 14,
                      color: isUrgent ? Colors.white : AppColors.primaryCoral,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$timerMins:$timerSecs',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isUrgent ? Colors.white : AppColors.primaryCoral,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Live Player Score Strip ---
  Widget _buildPlayerScoreStrip(GameState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: state.players.map((p) {
          final isDrawer = p.userId == state.drawerId;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: p.hasGuessed ? AppColors.secondaryContainer.withValues(alpha: 0.5) : Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                Stack(
                  children: [
                    AvatarWidget(
                      avatarUrl: p.avatarUrl,
                      displayName: p.displayName,
                      radius: 12,
                    ),
                    if (p.hasGuessed)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.accentMint,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.check, size: 8, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isDrawer ? '🎨 ${p.displayName}' : p.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${p.score} pts',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: p.hasGuessed ? AppColors.secondary : AppColors.primaryCoral,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Letter Blanks Banner ---
  Widget _buildLetterBlanksBanner(GameState state) {
    final blanks = state.letterBlanks.isNotEmpty ? state.letterBlanks : '_ _ _ _ _';
    final letters = blanks.split(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${letters.length} LETTERS:',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: letters.map((l) {
                    final isBlank = l == '_';
                    return Container(
                      width: 24,
                      height: 28,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: isBlank ? AppColors.surfaceContainerLow : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          if (!isBlank)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          l,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isBlank ? AppColors.textMuted : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, size: 16, color: AppColors.tertiary),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hint',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        state.hint ?? '1 hint left',
                        style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Guess Activity Stream ---
  Widget _buildGuessStream(List<GuessFeedItem> feed) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: feed.isEmpty
          ? Center(
              child: Text(
                'Type your guesses below! First correct guess wins max points.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
              ),
            )
          : ListView.builder(
              controller: _feedScrollController,
              itemCount: feed.length,
              itemBuilder: (context, index) {
                final item = feed[index];

                if (item.isCorrect) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${item.playerName} guessed the secret word!',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentMint.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${item.pointsEarned}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        '${item.playerName}: ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        item.text,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (item.isClose) ...[
                        const SizedBox(width: 6),
                        Text(
                          'close!',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryCoral,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  // --- Quick Emoji Reaction Ribbon ---
  Widget _buildReactionRibbon() {
    final emojis = ['🔥', '👏', '😂', '🤯', '❓'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: emojis.map((e) {
            return InkWell(
              onTap: () => _sendReaction(e),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(e, style: const TextStyle(fontSize: 22)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- Guess Input Row ---
  Widget _buildGuessInputRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _guessController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitGuess(),
              decoration: InputDecoration(
                hintText: 'Type your guess here...',
                hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.backspace_outlined, size: 18, color: AppColors.textMuted),
                  onPressed: () => _guessController.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.primaryCoral, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryCoralLight, AppColors.primaryCoral],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCoral.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _submitGuess,
            ),
          ),
        ],
      ),
    );
  }
}
