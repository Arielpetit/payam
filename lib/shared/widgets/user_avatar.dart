import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final String? initials;
  final double size;
  final bool showBadge;

  const UserAvatar({
    super.key,
    this.user,
    this.initials,
    this.size = 44,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = initials ?? user?.initials ?? '?';
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: size * 0.36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        if (showBadge)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
