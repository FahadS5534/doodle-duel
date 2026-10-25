import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/doodle_decorations.dart';
import '../../../../core/widgets/glass_card.dart';
import '../bloc/room_bloc.dart';

class DiscoverRoomsScreen extends StatefulWidget {
  const DiscoverRoomsScreen({super.key});

  @override
  State<DiscoverRoomsScreen> createState() => _DiscoverRoomsScreenState();
}

class _DiscoverRoomsScreenState extends State<DiscoverRoomsScreen> {
  String? _selectedDifficulty;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  void _fetchRooms() {
    context.read<RoomBloc>().add(
          RoomDiscoverRequested(
            difficulty: _selectedDifficulty,
            category: _selectedCategory,
          ),
        );
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
              'Discover Public Arenas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
                onPressed: _fetchRooms,
              ),
            ],
          ),
          body: AmbientDoodleBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Filter Chips Strip
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All Difficulties', _selectedDifficulty == null, () {
                            setState(() => _selectedDifficulty = null);
                            _fetchRooms();
                          }),
                          const SizedBox(width: 8),
                          _buildFilterChip('EASY', _selectedDifficulty == 'EASY', () {
                            setState(() => _selectedDifficulty = 'EASY');
                            _fetchRooms();
                          }),
                          const SizedBox(width: 8),
                          _buildFilterChip('MEDIUM', _selectedDifficulty == 'MEDIUM', () {
                            setState(() => _selectedDifficulty = 'MEDIUM');
                            _fetchRooms();
                          }),
                          const SizedBox(width: 8),
                          _buildFilterChip('HARD', _selectedDifficulty == 'HARD', () {
                            setState(() => _selectedDifficulty = 'HARD');
                            _fetchRooms();
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Room List
                  Expanded(
                    child: _buildBody(state),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primaryCoral,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Create Arena',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
            ),
            onPressed: () => context.push('/create-room'),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryFixed,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.primaryCoral : AppColors.textSecondary,
      ),
      onSelected: (_) => onTap(),
    );
  }

  Widget _buildBody(RoomState state) {
    if (state is RoomLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryCoral),
      );
    }

    if (state is RoomDiscoverLoaded) {
      final rooms = state.rooms;

      if (rooms.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.palette_outlined, size: 36, color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),
              Text(
                'No public rooms right now',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create your own room and invite rivals to duel!',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCoral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create New Room'),
                onPressed: () => context.push('/create-room'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: AppColors.primaryCoral,
        onRefresh: () async => _fetchRooms(),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: rooms.length,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final r = rooms[index];
            final isFull = r.members.length >= r.maxPlayers;
            final isPlaying = r.status == 'IN_GAME';

            return GlassCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isPlaying ? AppColors.accentYellow.withValues(alpha: 0.2) : AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        isPlaying ? Icons.sports_esports : Icons.palette,
                        color: isPlaying ? AppColors.tertiary : AppColors.primaryCoral,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.bgSecondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                r.difficulty,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${r.members.length}/${r.maxPlayers} players',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isFull ? AppColors.error : AppColors.accentMint,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFull || isPlaying
                          ? AppColors.surfaceContainer
                          : AppColors.primaryCoral,
                      foregroundColor: isFull || isPlaying
                          ? AppColors.textMuted
                          : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: isFull || isPlaying
                        ? null
                        : () {
                            context.read<RoomBloc>().add(RoomJoinRequested(r.roomCode));
                          },
                    child: Text(
                      isPlaying
                          ? 'In Match'
                          : isFull
                              ? 'Full'
                              : 'Join',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return const SizedBox();
  }
}
