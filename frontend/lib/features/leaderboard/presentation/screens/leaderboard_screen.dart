import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/doodle_decorations.dart';
import '../../../../core/widgets/glass_card.dart';

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final int totalScore;
  final int gamesWon;
  final int gamesPlayed;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.totalScore,
    required this.gamesWon,
    required this.gamesPlayed,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      avatarUrl: json['avatarUrl'],
      totalScore: json['totalScore'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String _period = 'weekly';
  List<LeaderboardEntry> _entries = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.dio.get(
        '/leaderboard',
        queryParameters: {'period': _period},
      );

      final data = response.data['data'] as List;
      final list = data.map((item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>)).toList();

      setState(() {
        _entries = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load rankings';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Champions Hall',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _fetchLeaderboard,
          ),
        ],
      ),
      body: AmbientDoodleBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Period Selector Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton('Weekly Duelists', 'weekly'),
                      ),
                      Expanded(
                        child: _buildTabButton('All-Time Legends', 'all-time'),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Ranking List
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    final isSelected = _period == value;

    return GestureDetector(
      onTap: () {
        if (_period != value) {
          setState(() => _period = value);
          _fetchLeaderboard();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryCoral : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryCoral),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: GoogleFonts.inter(color: AppColors.error)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchLeaderboard,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No matches recorded yet this $_period',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Play rooms to score points and claim the crown!',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryCoral,
      onRefresh: _fetchLeaderboard,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _entries.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final entry = _entries[index];
          final rank = entry.rank;

          String rankBadge = '#$rank';
          Color? badgeColor = AppColors.surfaceContainer;
          if (rank == 1) {
            rankBadge = '🥇';
            badgeColor = AppColors.accentYellow.withValues(alpha: 0.3);
          } else if (rank == 2) {
            rankBadge = '🥈';
            badgeColor = AppColors.surfaceContainerHigh;
          } else if (rank == 3) {
            rankBadge = '🥉';
            badgeColor = AppColors.primaryFixed;
          }

          return GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      rankBadge,
                      style: GoogleFonts.inter(
                        fontSize: rank <= 3 ? 16 : 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AvatarWidget(
                  avatarUrl: entry.avatarUrl,
                  displayName: entry.displayName,
                  radius: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.displayName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${entry.gamesWon} wins • ${entry.gamesPlayed} played',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: rank == 1 ? AppColors.primaryFixed : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entry.totalScore} pts',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: rank == 1 ? AppColors.primaryCoral : AppColors.textPrimary,
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
}
