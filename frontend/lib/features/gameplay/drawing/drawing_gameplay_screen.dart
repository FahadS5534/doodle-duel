import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../blocs/drawing_cubit.dart';
import '../blocs/game_bloc.dart';
import 'drawing_canvas.dart';

class DrawingGameplayScreen extends StatefulWidget {
  final GameState gameState;

  const DrawingGameplayScreen({super.key, required this.gameState});

  @override
  State<DrawingGameplayScreen> createState() => _DrawingGameplayScreenState();
}

class _DrawingGameplayScreenState extends State<DrawingGameplayScreen> {
  final List<String> _swatchHexes = [
    '#22252A', // Charcoal Black
    '#FF5733', // Vivid Coral
    '#2EC4B6', // Mint
    '#FFD166', // Yellow
    '#B8A9C9', // Lavender
    '#38D9A9', // Bright Mint
    '#FFFFFF', // Eraser White
  ];

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;
    final drawingCubit = context.watch<DrawingCubit>();
    final drawingState = drawingCubit.state;

    return Scaffold(
      backgroundColor: AppColors.bgRoot,
      body: SafeArea(
        child: Column(
          children: [
            // Top Status & Game Progress Header
            _buildTopHeader(state),

            // Live Players Horizontal Score Strip
            _buildScoreStrip(state),
            const SizedBox(height: 6),

            // Drawer Secret Prompt Banner
            _buildSecretPromptBanner(state),
            const SizedBox(height: 8),

            // Primary Drawing Canvas with Live Guess Feed Overlay
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB49682).withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // The interactive touch canvas
                        const DrawingCanvas(isReadOnly: false),

                        // Top Canvas Actions: Undo, Redo, Clear
                        Positioned(
                          top: 10,
                          left: 10,
                          right: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GlassCard(
                                borderRadius: 14,
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.undo, size: 20, color: AppColors.textPrimary),
                                      onPressed: drawingState.canUndo ? drawingCubit.undo : null,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.redo, size: 20, color: AppColors.textSecondary),
                                      onPressed: drawingState.canRedo ? drawingCubit.redo : null,
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                                  foregroundColor: AppColors.error,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                icon: const Icon(Icons.delete_sweep, size: 18),
                                label: Text(
                                  'Clear',
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                                onPressed: () {
                                  _confirmClear(context, drawingCubit);
                                },
                              ),
                            ],
                          ),
                        ),

                        // Live Guess Feed Overlay (Stacked Bottom Right Inside Canvas)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: _buildLiveGuessOverlay(state.guessFeed),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Floating Palette & Control Toolbar
            _buildPaletteToolbar(drawingCubit, drawingState),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildTopHeader(GameState state) {
    final timerMins = (state.remainingSeconds ~/ 60).toString();
    final timerSecs = (state.remainingSeconds % 60).toString().padLeft(2, '0');
    final isUrgent = state.remainingSeconds <= 10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.replay, size: 16, color: AppColors.primaryCoral),
                const SizedBox(width: 6),
                Text(
                  'ROUND ${state.currentRound} OF ${state.totalRounds}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.primaryCoral
                  : AppColors.primaryCoral.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: isUrgent ? Colors.white : AppColors.primaryCoral,
                ),
                const SizedBox(width: 6),
                Text(
                  '$timerMins:$timerSecs',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isUrgent ? Colors.white : AppColors.primaryCoral,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Scores Strip ---
  Widget _buildScoreStrip(GameState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: state.players.map((p) {
          final isYou = p.userId == state.drawerId;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isYou ? Colors.white : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (isYou)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                if (isYou) ...[
                  const Text('👑', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                ],
                Text(
                  isYou ? 'You' : p.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isYou ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isYou ? AppColors.accentMint.withValues(alpha: 0.2) : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${p.score}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isYou ? AppColors.secondary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Secret Word Banner ---
  Widget _buildSecretPromptBanner(GameState state) {
    final word = state.secretWord ?? 'Secret Prompt';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'YOUR SECRET PROMPT',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+150 pts',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('🎨', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      word,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryCoral,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.category, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    state.category ?? 'GENERAL',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Live Guess Overlay inside Canvas ---
  Widget _buildLiveGuessOverlay(List<GuessFeedItem> feed) {
    if (feed.isEmpty) return const SizedBox();

    final recentGuesses = feed.length > 3 ? feed.sublist(feed.length - 3) : feed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: recentGuesses.map((g) {
        if (g.isCorrect) {
          return Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accentMint.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentMint.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${g.playerName} guessed right! +${g.pointsEarned}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            '${g.playerName}: ${g.text} ${g.isClose ? "🤔 close!" : "❌"}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: g.isClose ? AppColors.primaryCoral : AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Palette & Control Toolbar ---
  Widget _buildPaletteToolbar(DrawingCubit cubit, DrawingState state) {
    final isEraser = state.selectedTool == 'ERASER';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          children: [
            // Stroke Sizes & Tools Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tool Toggle: Pen vs Eraser
                Row(
                  children: [
                    _buildToolButton(
                      Icons.edit,
                      'Pen',
                      !isEraser,
                      () => cubit.setTool('PEN'),
                    ),
                    const SizedBox(width: 8),
                    _buildToolButton(
                      Icons.auto_fix_normal,
                      'Eraser',
                      isEraser,
                      () => cubit.setTool('ERASER'),
                    ),
                  ],
                ),

                // Stroke Width Chips
                Row(
                  children: [
                    _buildStrokeSize(2, cubit, state.selectedBrushSize),
                    _buildStrokeSize(5, cubit, state.selectedBrushSize),
                    _buildStrokeSize(10, cubit, state.selectedBrushSize),
                    _buildStrokeSize(16, cubit, state.selectedBrushSize),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Color Swatches
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _swatchHexes.map((hex) {
                final color = _hexToColor(hex);
                final isSelected = state.selectedColor.toUpperCase() == hex.toUpperCase();

                return GestureDetector(
                  onTap: () {
                    cubit.setTool('PEN');
                    cubit.setColor(hex);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryCoral : Colors.black12,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.primaryCoral.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: isSelected
                        ? Center(
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: color == Colors.white ? AppColors.textPrimary : Colors.white,
                            ),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryCoral : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrokeSize(double size, DrawingCubit cubit, double currentSize) {
    final isSelected = (currentSize - size).abs() < 1;

    return GestureDetector(
      onTap: () => cubit.setBrushSize(size),
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryFixed : AppColors.surfaceContainerLow,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: AppColors.primaryCoral, width: 1.5) : null,
        ),
        child: Center(
          child: Container(
            width: size.clamp(3, 14),
            height: size.clamp(3, 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryCoral : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, DrawingCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Canvas?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to erase your entire drawing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              cubit.clear();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
