import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget for displaying a thought item in a list
/// Unified design matching category cards - soft, matte, consistent
class ThoughtItem extends StatelessWidget {
  final String text;
  final DateTime createdAt;
  final VoidCallback onTap;
  final String category;

  const ThoughtItem({
    super.key,
    required this.text,
    required this.createdAt,
    required this.onTap,
    this.category = '',
  });

  /// Get first line of text for preview
  String _getPreview() {
    final lines = text.split('\n');
    final firstLine = lines.first.trim();
    if (firstLine.length > 100) {
      return '${firstLine.substring(0, 100)}...';
    }
    return firstLine;
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  /// Get category color accent (using consistent palette)
  Color _getCategoryColor() {
    const primaryColor = Color(0xFF4b3832);
    const secondaryColor = Color(0xFF854442);
    const highlightColor = Color(0xFFbe9b7b);
    
    switch (category) {
      case 'Ideas':
        return secondaryColor;
      case 'Worries':
        return primaryColor;
      case 'Tasks':
        return highlightColor;
      case 'Random':
        return secondaryColor;
      default:
        return primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor();
    const darkAccentColor = Color(0xFF3c2f2f);

    return Card(
      elevation: 2,
      shadowColor: darkAccentColor.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // Subtle left border accent - no gradient
              border: Border(
                left: BorderSide(
                  color: categoryColor.withValues(alpha: 0.4),
                  width: 4,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getPreview(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: darkAccentColor,
                    height: 1.6,
                    letterSpacing: 0.2,
                    fontSize: 15,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: darkAccentColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: darkAccentColor.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
