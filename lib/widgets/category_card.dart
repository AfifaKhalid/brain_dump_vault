import 'package:flutter/material.dart';

/// Widget for displaying a category as a full-width list card
class CategoryCard extends StatefulWidget {
  final String category;
  final int thoughtCount;
  final VoidCallback onTap;
  final int index;

  const CategoryCard({
    super.key,
    required this.category,
    required this.thoughtCount,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 90), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon() {
    switch (widget.category) {
      case 'Ideas':
        return Icons.lightbulb_rounded;
      case 'Worries':
        return Icons.psychology_rounded;
      case 'Tasks':
        return Icons.check_circle_rounded;
      case 'Random':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  Color _getCategoryAccent() {
    switch (widget.category) {
      case 'Ideas':
        return const Color(0xFF854442);
      case 'Worries':
        return const Color(0xFF4b3832);
      case 'Tasks':
        return const Color(0xFFbe9b7b);
      case 'Random':
        return const Color(0xFF854442);
      default:
        return const Color(0xFF4b3832);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _getCategoryAccent();
    const textColor = Color(0xFF3c2f2f);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E6),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                /// Icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accent.withAlpha(45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getCategoryIcon(), size: 28, color: accent),
                ),

                const SizedBox(width: 16),

                /// Category name
                Expanded(
                  child: Text(
                    widget.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),

                /// Count (right side, subtle)
                Text(
                  widget.thoughtCount.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor.withAlpha(120),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
