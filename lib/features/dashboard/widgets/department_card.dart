import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class DepartmentCard extends StatefulWidget {
  final String name;
  final int totalClasses;
  final bool isAccessible;
  final VoidCallback? onTap;

  const DepartmentCard({
    super.key,
    required this.name,
    required this.totalClasses,
    required this.isAccessible,
    this.onTap,
  });

  @override
  State<DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<DepartmentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isAccessible) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isAccessible) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isAccessible) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: widget.isAccessible ? _opacityAnimation.value : 0.5,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isAccessible
                        ? (_isPressed
                            ? _getDepartmentColor(widget.name).withOpacity(0.5)
                            : AppColors.grey200)
                        : AppColors.grey300,
                    width: _isPressed ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isAccessible
                          ? (_isPressed
                              ? _getDepartmentColor(widget.name)
                                  .withOpacity(0.2)
                              : Colors.black.withOpacity(0.08))
                          : Colors.black.withOpacity(0.04),
                      blurRadius: _isPressed ? 16 : 12,
                      offset: Offset(0, _isPressed ? 8 : 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Department icon with gradient
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _getDepartmentGradient(widget.name),
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getDepartmentColor(widget.name)
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Background pattern (optional)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.2),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Department letter
                                  Center(
                                    child: Text(
                                      widget.name[0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Department name
                      Text(
                        '${widget.name}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.isAccessible
                              ? AppColors.grey800
                              : AppColors.grey500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Class count with icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: widget.isAccessible
                                ? AppColors.grey600
                                : AppColors.grey400,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${widget.totalClasses} lớp',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: widget.isAccessible
                                    ? AppColors.grey600
                                    : AppColors.grey400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // Access indicator
                      if (!widget.isAccessible) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.grey300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 12,
                                color: AppColors.grey500,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Không có quyền',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.grey500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Hover effect indicator
                      if (widget.isAccessible) ...[
                        const SizedBox(height: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          width: _isPressed ? 40 : 20,
                          decoration: BoxDecoration(
                            color: _getDepartmentColor(widget.name)
                                .withOpacity(_isPressed ? 0.8 : 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
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

  Color _getDepartmentColor(String department) {
    switch (department) {
      case 'Chiên':
        return AppColors.chienColor;
      case 'Âu':
        return AppColors.auColor;
      case 'Thiếu':
        return AppColors.thieuColor;
      case 'Nghĩa':
        return AppColors.nghiaColor;
      default:
        return AppColors.primary;
    }
  }

  List<Color> _getDepartmentGradient(String department) {
    switch (department) {
      case 'Chiên':
        return [
          AppColors.chienColor,
          const Color(0xFFFC8181),
          const Color(0xFFFEB2B2),
        ];
      case 'Âu':
        return [
          AppColors.auColor,
          const Color(0xFF63B3ED),
          const Color(0xFF90CDF4),
        ];
      case 'Thiếu':
        return [
          AppColors.thieuColor,
          const Color(0xFF68D391),
          const Color(0xFF9AE6B4),
        ];
      case 'Nghĩa':
        return [
          AppColors.nghiaColor,
          const Color(0xFFB794F6),
          const Color(0xFFD6BCFA),
        ];
      default:
        return AppColors.primaryGradient;
    }
  }
}
