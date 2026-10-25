import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/coral_button.dart';
import '../../../../core/widgets/doodle_decorations.dart';
import '../../../../core/widgets/glass_card.dart';
import '../bloc/room_bloc.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "Doodlers' Lounge");

  bool _isPublic = true;
  int _maxPlayers = 8;
  int _rounds = 4;
  int _drawTimeSeconds = 60;
  String _difficulty = 'MEDIUM';
  String _category = 'GENERAL';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<RoomBloc>().add(
            RoomCreateRequested(
              name: _nameController.text.trim(),
              visibility: _isPublic ? 'PUBLIC' : 'PRIVATE',
              maxPlayers: _maxPlayers,
              totalRounds: _rounds,
              drawTimeSeconds: _drawTimeSeconds,
              difficulty: _difficulty,
              category: _category,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomBloc, RoomState>(
      listener: (context, state) {
        if (state is RoomActionSuccess) {
          context.go('/lobby/${state.room.id}');
        } else if (state is RoomError) {
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
        final isLoading = state is RoomLoading;

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
              'Create Match Room',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Room Name Input
                      GlassCard(
                        borderRadius: 22,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Room Name',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              maxLength: 30,
                              decoration: InputDecoration(
                                hintText: 'Enter room title...',
                                prefixIcon: const Icon(Icons.meeting_room, color: AppColors.primaryCoral),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: AppColors.borderSubtle),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: AppColors.borderSubtle),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: AppColors.primaryCoral, width: 2),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please provide a room name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Visibility Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _isPublic ? Icons.public : Icons.lock,
                                      size: 18,
                                      color: _isPublic ? AppColors.accentMint : AppColors.primaryCoral,
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isPublic ? 'Public Room' : 'Private Match',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          _isPublic
                                              ? 'Anyone can discover & join'
                                              : 'Invite-only with 8-character code',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Switch.adaptive(
                                  value: _isPublic,
                                  activeTrackColor: AppColors.accentMint,
                                  onChanged: (val) => setState(() => _isPublic = val),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Match Rules Glass Card
                      GlassCard(
                        borderRadius: 22,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Match Settings',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Max Players
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Max Players', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                                Text('$_maxPlayers players', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryCoral)),
                              ],
                            ),
                            Slider(
                              value: _maxPlayers.toDouble(),
                              min: 2,
                              max: 8,
                              divisions: 6,
                              activeColor: AppColors.primaryCoral,
                              onChanged: (v) => setState(() => _maxPlayers = v.toInt()),
                            ),
                            const SizedBox(height: 10),

                            // Rounds
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Number of Rounds', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                                Text('$_rounds rounds', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryCoral)),
                              ],
                            ),
                            Slider(
                              value: _rounds.toDouble(),
                              min: 2,
                              max: 8,
                              divisions: 6,
                              activeColor: AppColors.primaryCoral,
                              onChanged: (v) => setState(() => _rounds = v.toInt()),
                            ),
                            const SizedBox(height: 10),

                            // Drawing Duration
                            Text('Drawing Time per Round', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Row(
                              children: [45, 60, 80, 100].map((sec) {
                                final isSel = _drawTimeSeconds == sec;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: ChoiceChip(
                                      label: Text('${sec}s'),
                                      selected: isSel,
                                      selectedColor: AppColors.primaryCoral,
                                      labelStyle: TextStyle(
                                        color: isSel ? Colors.white : AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      onSelected: (val) {
                                        if (val) setState(() => _drawTimeSeconds = sec);
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),

                            // Difficulty
                            Text('Word Difficulty', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Row(
                              children: ['EASY', 'MEDIUM', 'HARD'].map((diff) {
                                final isSel = _difficulty == diff;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: ChoiceChip(
                                      label: Text(diff),
                                      selected: isSel,
                                      selectedColor: AppColors.accentMint,
                                      labelStyle: TextStyle(
                                        color: isSel ? Colors.white : AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                      onSelected: (val) {
                                        if (val) setState(() => _difficulty = diff);
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),

                            // Category
                            Text('Category Pack', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ['GENERAL', 'ANIMALS', 'FOOD', 'TECH', 'NATURE'].map((cat) {
                                final isSel = _category == cat;
                                return ChoiceChip(
                                  label: Text(cat),
                                  selected: isSel,
                                  selectedColor: AppColors.primaryFixed,
                                  labelStyle: TextStyle(
                                    color: isSel ? AppColors.primaryCoral : AppColors.textPrimary,
                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  onSelected: (val) {
                                    if (val) setState(() => _category = cat);
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Settings Summary Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(Icons.group, '$_maxPlayers Players'),
                            _buildSummaryItem(Icons.replay, '$_rounds Rounds'),
                            _buildSummaryItem(Icons.timer, '${_drawTimeSeconds}s Turn'),
                            _buildSummaryItem(Icons.tune, _difficulty),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit CTA Button
                      CoralButton(
                        text: 'Launch Match Lobby',
                        isLoading: isLoading,
                        icon: const Icon(Icons.palette, color: Colors.white, size: 20),
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryCoral),
        const SizedBox(height: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
