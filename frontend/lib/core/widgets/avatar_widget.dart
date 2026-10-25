import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String? name;
  final String? displayName;
  final double? size;
  final double? radius;
  final bool isHost;
  final bool isOnline;
  final bool isDrawing;
  final bool showBorder;
  final Color? borderColor;

  const AvatarWidget({
    super.key,
    this.avatarUrl,
    this.name,
    this.displayName,
    this.size,
    this.radius,
    this.isHost = false,
    this.isOnline = true,
    this.isDrawing = false,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveName = displayName ?? name ?? 'Player';
    final effectiveSize = radius != null ? radius! * 2 : (size ?? 44.0);

    final initials = effectiveName.isNotEmpty
        ? effectiveName.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase()
        : '?';

    final effectiveBorderColor = borderColor ??
        (isDrawing ? AppColors.primaryCoral : (showBorder ? AppColors.primaryCoral : Colors.white));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: effectiveSize,
          height: effectiveSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentLavenderSubtle,
            border: Border.all(
              color: effectiveBorderColor,
              width: (isDrawing || showBorder) ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl!.startsWith('http')
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, err, stack) => _buildFallback(initials, effectiveSize),
                  )
                : _buildFallback(initials, effectiveSize),
          ),
        ),

        // Host Crown Badge
        if (isHost)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.accentYellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text('👑', style: TextStyle(fontSize: 12)),
            ),
          ),

        // Online Indicator
        if (isOnline && !isHost && !showBorder)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: effectiveSize * 0.28,
              height: effectiveSize * 0.28,
              decoration: BoxDecoration(
                color: isDrawing ? AppColors.primaryCoral : AppColors.accentMint,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallback(String initials, double effectiveSize) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.plusJakartaSans(
          fontSize: effectiveSize * 0.38,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
