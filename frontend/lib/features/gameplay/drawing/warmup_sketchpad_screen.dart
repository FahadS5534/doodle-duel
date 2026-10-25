import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../blocs/drawing_cubit.dart';
import 'drawing_canvas.dart';

class DoodlePrompt {
  final String word;
  final String category;
  final String emoji;
  final String difficulty; // Easy, Medium, Hard

  const DoodlePrompt({
    required this.word,
    required this.category,
    required this.emoji,
    this.difficulty = 'Easy',
  });
}

class WarmupSketchpadScreen extends StatelessWidget {
  const WarmupSketchpadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DrawingCubit(
        roomId: 'solo-practice',
        isLocal: true,
      ),
      child: const _WarmupSketchpadView(),
    );
  }
}

class _WarmupSketchpadView extends StatefulWidget {
  const _WarmupSketchpadView();

  @override
  State<_WarmupSketchpadView> createState() => _WarmupSketchpadViewState();
}

class _WarmupSketchpadViewState extends State<_WarmupSketchpadView>
    with SingleTickerProviderStateMixin {
  static const List<DoodlePrompt> _promptBank = [
    // 🍕 Food
    DoodlePrompt(word: 'Pizza Slice', category: 'Food', emoji: '🍕', difficulty: 'Easy'),
    DoodlePrompt(word: 'Cheeseburger', category: 'Food', emoji: '🍔', difficulty: 'Easy'),
    DoodlePrompt(word: 'Ice Cream Cone', category: 'Food', emoji: '🍦', difficulty: 'Easy'),
    DoodlePrompt(word: 'Taco', category: 'Food', emoji: '🌮', difficulty: 'Easy'),
    DoodlePrompt(word: 'Glazed Donut', category: 'Food', emoji: '🍩', difficulty: 'Easy'),
    DoodlePrompt(word: 'Sushi Roll', category: 'Food', emoji: '🍣', difficulty: 'Medium'),
    DoodlePrompt(word: 'Cupcake with Cherry', category: 'Food', emoji: '🧁', difficulty: 'Medium'),
    DoodlePrompt(word: 'Hot Dog with Mustard', category: 'Food', emoji: '🌭', difficulty: 'Easy'),
    DoodlePrompt(word: 'Pancake Stack', category: 'Food', emoji: '🥞', difficulty: 'Medium'),
    DoodlePrompt(word: 'Watermelon Slice', category: 'Food', emoji: '🍉', difficulty: 'Easy'),
    DoodlePrompt(word: 'Popcorn Bucket', category: 'Food', emoji: '🍿', difficulty: 'Medium'),
    DoodlePrompt(word: 'French Fries', category: 'Food', emoji: '🍟', difficulty: 'Easy'),
    DoodlePrompt(word: 'Boba Bubble Tea', category: 'Food', emoji: '🧋', difficulty: 'Medium'),

    // 🐶 Animals
    DoodlePrompt(word: 'Golden Retriever', category: 'Animals', emoji: '🐶', difficulty: 'Medium'),
    DoodlePrompt(word: 'Playful Cat', category: 'Animals', emoji: '🐱', difficulty: 'Easy'),
    DoodlePrompt(word: 'Wise Owl', category: 'Animals', emoji: '🦉', difficulty: 'Medium'),
    DoodlePrompt(word: 'Jumping Dolphin', category: 'Animals', emoji: '🐬', difficulty: 'Medium'),
    DoodlePrompt(word: 'Panda Bear', category: 'Animals', emoji: '🐼', difficulty: 'Easy'),
    DoodlePrompt(word: 'Penguin on Ice', category: 'Animals', emoji: '🐧', difficulty: 'Easy'),
    DoodlePrompt(word: 'Chameleon', category: 'Animals', emoji: '🦎', difficulty: 'Hard'),
    DoodlePrompt(word: 'Roaring Lion', category: 'Animals', emoji: '🦁', difficulty: 'Medium'),
    DoodlePrompt(word: 'Baby Elephant', category: 'Animals', emoji: '🐘', difficulty: 'Medium'),
    DoodlePrompt(word: 'Sea Turtle', category: 'Animals', emoji: '🐢', difficulty: 'Medium'),
    DoodlePrompt(word: 'Flamingo', category: 'Animals', emoji: '🦩', difficulty: 'Medium'),
    DoodlePrompt(word: 'Butterfly', category: 'Animals', emoji: '🦋', difficulty: 'Easy'),
    DoodlePrompt(word: 'Koala on Tree', category: 'Animals', emoji: '🐨', difficulty: 'Medium'),

    // 🚀 Objects & Space
    DoodlePrompt(word: 'Space Rocket', category: 'Objects', emoji: '🚀', difficulty: 'Medium'),
    DoodlePrompt(word: 'Astronaut Helmet', category: 'Objects', emoji: '👨‍🚀', difficulty: 'Hard'),
    DoodlePrompt(word: 'Planet Saturn', category: 'Objects', emoji: '🪐', difficulty: 'Easy'),
    DoodlePrompt(word: 'Hot Air Balloon', category: 'Objects', emoji: '🎈', difficulty: 'Medium'),
    DoodlePrompt(word: 'Vintage Camera', category: 'Objects', emoji: '📷', difficulty: 'Medium'),
    DoodlePrompt(word: 'Electric Guitar', category: 'Objects', emoji: '🎸', difficulty: 'Medium'),
    DoodlePrompt(word: 'Headphones', category: 'Objects', emoji: '🎧', difficulty: 'Easy'),
    DoodlePrompt(word: 'Lighthouse', category: 'Objects', emoji: '🏮', difficulty: 'Medium'),
    DoodlePrompt(word: 'Treasure Chest', category: 'Objects', emoji: '💎', difficulty: 'Medium'),
    DoodlePrompt(word: 'Grand Piano', category: 'Objects', emoji: '🎹', difficulty: 'Hard'),
    DoodlePrompt(word: 'Submarine', category: 'Objects', emoji: '🚢', difficulty: 'Medium'),
    DoodlePrompt(word: 'Microscope', category: 'Objects', emoji: '🔬', difficulty: 'Hard'),

    // 🏰 Nature & Places
    DoodlePrompt(word: 'Campfire', category: 'Nature', emoji: '🔥', difficulty: 'Easy'),
    DoodlePrompt(word: 'Eiffel Tower', category: 'Nature', emoji: '🗼', difficulty: 'Hard'),
    DoodlePrompt(word: 'Volcano Eruption', category: 'Nature', emoji: '🌋', difficulty: 'Medium'),
    DoodlePrompt(word: 'Desert Island', category: 'Nature', emoji: '🏝️', difficulty: 'Easy'),
    DoodlePrompt(word: 'Snowman with Scarf', category: 'Nature', emoji: '☃️', difficulty: 'Easy'),
    DoodlePrompt(word: 'Rainbow Waterfall', category: 'Nature', emoji: '🌈', difficulty: 'Medium'),
    DoodlePrompt(word: 'Cactus with Flower', category: 'Nature', emoji: '🌵', difficulty: 'Easy'),
    DoodlePrompt(word: 'Haunted Castle', category: 'Nature', emoji: '🏰', difficulty: 'Hard'),

    // ⚡ Fantasy & Fun
    DoodlePrompt(word: 'Fire Dragon', category: 'Fantasy', emoji: '🐉', difficulty: 'Hard'),
    DoodlePrompt(word: 'Unicorn', category: 'Fantasy', emoji: '🦄', difficulty: 'Medium'),
    DoodlePrompt(word: 'Wizard Hat', category: 'Fantasy', emoji: '🧙', difficulty: 'Easy'),
    DoodlePrompt(word: 'Alien in UFO', category: 'Fantasy', emoji: '🛸', difficulty: 'Medium'),
    DoodlePrompt(word: 'Magic Lamp', category: 'Fantasy', emoji: '🪔', difficulty: 'Easy'),
    DoodlePrompt(word: 'Superhero Cape', category: 'Fantasy', emoji: '🦸', difficulty: 'Easy'),
  ];

  final List<String> _swatchHexes = [
    '#22252A', // Charcoal Black
    '#FF5733', // Vivid Coral
    '#2EC4B6', // Mint
    '#FFD166', // Yellow
    '#B8A9C9', // Lavender
    '#38D9A9', // Bright Mint
    '#1D3557', // Deep Navy
    '#E63946', // Ruby Red
    '#FFFFFF', // Eraser White
  ];

  late DoodlePrompt _currentPrompt;
  String _selectedCategory = 'All';
  bool _isWordHidden = false;

  // Practice Timer
  int _timerDurationSeconds = 0; // 0 = untimed
  int _secondsRemaining = 0;
  Timer? _countdownTimer;
  bool _isTimerRunning = false;

  late AnimationController _rollAnimationController;

  @override
  void initState() {
    super.initState();
    _currentPrompt = _promptBank[Random().nextInt(_promptBank.length)];
    _rollAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _rollAnimationController.dispose();
    super.dispose();
  }

  void _rollNewPrompt() {
    _rollAnimationController.forward(from: 0.0);

    final filtered = _selectedCategory == 'All'
        ? _promptBank
        : _promptBank.where((p) => p.category == _selectedCategory).toList();

    if (filtered.isEmpty) return;

    DoodlePrompt next;
    do {
      next = filtered[Random().nextInt(filtered.length)];
    } while (next.word == _currentPrompt.word && filtered.length > 1);

    setState(() {
      _currentPrompt = next;
      _isWordHidden = false;
    });

    if (_timerDurationSeconds > 0) {
      _startPracticeTimer(_timerDurationSeconds);
    }
  }

  void _setCategory(String category) {
    setState(() => _selectedCategory = category);
    _rollNewPrompt();
  }

  void _startPracticeTimer(int seconds) {
    _countdownTimer?.cancel();
    setState(() {
      _timerDurationSeconds = seconds;
      _secondsRemaining = seconds;
      _isTimerRunning = true;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _isTimerRunning = false;
        });
        _showTimeUpDialog();
      }
    });
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _timerDurationSeconds = 0;
      _secondsRemaining = 0;
      _isTimerRunning = false;
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text('⏰', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              'Time is Up!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Great warm-up session! You drew "${_currentPrompt.word}".',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryCoral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ready to test your skills against real players?',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryCoral,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Keep Drawing',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _rollNewPrompt();
            },
            child: Text(
              'Next Word 🎲',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, DrawingCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Clear Canvas?',
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will wipe your current sketchpad doodle clean.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              cubit.clearCanvas();
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Clear',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DrawingCubit>();
    final state = cubit.state;

    return Scaffold(
      backgroundColor: AppColors.bgRoot,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopNavBar(),

            // Category Filter Chips
            _buildCategoryFilterRow(),
            const SizedBox(height: 6),

            // Word Prompt Showcase Card
            _buildPromptShowcaseCard(),
            const SizedBox(height: 8),

            // Primary Interactive Canvas
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
                        // The interactive CustomPainter canvas
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
                                      onPressed: state.canUndo ? cubit.undo : null,
                                      tooltip: 'Undo',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.redo, size: 20, color: AppColors.textSecondary),
                                      onPressed: state.canRedo ? cubit.redo : null,
                                      tooltip: 'Redo',
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  // Quick Timer Selector Button
                                  _buildTimerMenuButton(),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(alpha: 0.92),
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
                                    onPressed: () => _confirmClear(context, cubit),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Active Timer Pill (if timer is active)
                        if (_isTimerRunning || _secondsRemaining > 0)
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: _buildTimerBadge(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Creative Palette & Controls Toolbar
            _buildPaletteToolbar(cubit, state),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // --- Top Nav Bar ---
  Widget _buildTopNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
            onPressed: () => context.pop(),
          ),
          Column(
            children: [
              Text(
                'Warm-up Sketchpad',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.accentMint,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Solo Practice • No Room Required',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCoral,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.sports_esports, size: 16),
            label: Text(
              'Duel',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            onPressed: () => context.push('/create-room'),
          ),
        ],
      ),
    );
  }

  // --- Category Filter Row ---
  Widget _buildCategoryFilterRow() {
    final categories = ['All', 'Food', 'Animals', 'Objects', 'Nature', 'Fantasy'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(cat),
              labelStyle: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryCoral,
              backgroundColor: AppColors.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              onSelected: (_) => _setCategory(cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Prompt Showcase Card ---
  Widget _buildPromptShowcaseCard() {
    final difficultyColor = switch (_currentPrompt.difficulty) {
      'Easy' => AppColors.accentMint,
      'Medium' => AppColors.accentYellow,
      _ => AppColors.primaryCoral,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'WORD TO DOODLE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: difficultyColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentPrompt.difficulty,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: difficultyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(_currentPrompt.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isWordHidden ? '••••••••••' : _currentPrompt.word,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryCoral,
                            letterSpacing: 0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isWordHidden ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setState(() => _isWordHidden = !_isWordHidden),
                        tooltip: _isWordHidden ? 'Reveal Word' : 'Hide Word',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Roll New Word Action Button
            RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_rollAnimationController),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCoral.withValues(alpha: 0.15),
                  foregroundColor: AppColors.primaryCoral,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                icon: const Icon(Icons.casino, size: 18),
                label: Text(
                  'Roll',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800),
                ),
                onPressed: _rollNewPrompt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Timer Badge ---
  Widget _buildTimerBadge() {
    final mins = (_secondsRemaining ~/ 60).toString();
    final secs = (_secondsRemaining % 60).toString().padLeft(2, '0');
    final isUrgent = _secondsRemaining <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.primaryCoral : AppColors.textPrimary.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '$mins:$secs',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _stopTimer,
            child: const Icon(Icons.close, size: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // --- Timer Menu Button ---
  Widget _buildTimerMenuButton() {
    return PopupMenuButton<int>(
      tooltip: 'Practice Timer',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.surfaceContainerLow,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _isTimerRunning ? AppColors.primaryCoral.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.timer,
          size: 18,
          color: _isTimerRunning ? AppColors.primaryCoral : AppColors.textPrimary,
        ),
      ),
      onSelected: (seconds) {
        if (seconds == 0) {
          _stopTimer();
        } else {
          _startPracticeTimer(seconds);
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: 0,
          child: Text('Untimed (Free Doodle)'),
        ),
        const PopupMenuItem(
          value: 30,
          child: Text('30s Speed Sprint'),
        ),
        const PopupMenuItem(
          value: 60,
          child: Text('60s Standard Round'),
        ),
        const PopupMenuItem(
          value: 90,
          child: Text('90s Relaxed'),
        ),
      ],
    );
  }

  // --- Creative Palette & Controls Toolbar ---
  Widget _buildPaletteToolbar(DrawingCubit cubit, DrawingState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB49682).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Brush Tool Selection & Brush Size Preview Slider
          Row(
            children: [
              // Tool Selector: Pen, Glow, Eraser
              _buildToolButton(
                icon: Icons.edit,
                label: 'Pen',
                isSelected: state.selectedTool == 'PEN',
                onTap: () => cubit.setTool('PEN'),
              ),
              const SizedBox(width: 6),
              _buildToolButton(
                icon: Icons.auto_awesome,
                label: 'Glow',
                isSelected: state.selectedTool == 'GLOW',
                onTap: () => cubit.setTool('GLOW'),
              ),
              const SizedBox(width: 6),
              _buildToolButton(
                icon: Icons.cleaning_services,
                label: 'Eraser',
                isSelected: state.selectedTool == 'ERASER',
                onTap: () => cubit.setTool('ERASER'),
              ),
              const SizedBox(width: 12),

              // Brush Size Indicator Dot
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                ),
                child: Center(
                  child: Container(
                    width: state.selectedBrushSize.clamp(4.0, 24.0),
                    height: state.selectedBrushSize.clamp(4.0, 24.0),
                    decoration: BoxDecoration(
                      color: state.selectedTool == 'ERASER'
                          ? Colors.grey.shade400
                          : _hexToColor(state.selectedColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // Brush Size Slider
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primaryCoral,
                    inactiveTrackColor: AppColors.surfaceContainerHigh,
                    thumbColor: AppColors.primaryCoral,
                    overlayColor: AppColors.primaryCoral.withValues(alpha: 0.15),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: state.selectedBrushSize,
                    min: 2.0,
                    max: 32.0,
                    onChanged: (val) => cubit.setBrushSize(val),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Color Swatches Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _swatchHexes.map((hex) {
                final color = _hexToColor(hex);
                final isSelected = state.selectedColor.toUpperCase() == hex.toUpperCase() &&
                    state.selectedTool != 'ERASER';

                return GestureDetector(
                  onTap: () {
                    cubit.setColor(hex);
                    if (state.selectedTool == 'ERASER') {
                      cubit.setTool('PEN');
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryCoral
                            : (hex == '#FFFFFF' ? AppColors.borderSubtle : Colors.transparent),
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.primaryCoral.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: hex == '#FFFFFF' || hex == '#FFD166' ? Colors.black : Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryCoral : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
