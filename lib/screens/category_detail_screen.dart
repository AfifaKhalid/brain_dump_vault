import 'dart:async';
import 'package:flutter/material.dart';
import '../models/thought.dart';
import '../services/hive_service.dart';
import 'add_thought_screen.dart';
import 'thought_detail_screen.dart';

/// Screen displaying all thoughts in a specific category
class CategoryDetailScreen extends StatefulWidget {
  final String category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<Thought> _thoughts = [];
  Timer? _timer;

  bool get _isTasksCategory => widget.category == 'Tasks';

  @override
  void initState() {
    super.initState();
    _loadThoughts();

    /// Rebuild every minute to update relative timestamps
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadThoughts() {
    setState(() {
      _thoughts = HiveService.getThoughtsByCategory(widget.category);
    });
  }

  void _toggleTaskCompletion(Thought thought, bool value) {
    setState(() {
      thought.isCompleted = value;
      thought.save();
    });
  }

  void _navigateToThoughtDetail(Thought thought) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ThoughtDetailScreen(thought: thought)),
    );
    _loadThoughts();
  }

  void _navigateToAddThought() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddThoughtScreen(initialCategory: widget.category),
      ),
    );
    _loadThoughts();
  }

  /// Converts DateTime to relative time (Just now, 5 min ago, etc.)
  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4b3832);
    const secondaryColor = Color(0xFF854442);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(elevation: 0, title: Text(widget.category)),
      body: SafeArea(
        top: true,
        bottom: false,
        child: _thoughts.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: EdgeInsets.only(top: 12, bottom: bottomPadding + 80),
                itemCount: _thoughts.length,
                itemBuilder: (context, index) {
                  final thought = _thoughts[index];

                  /// TASKS CATEGORY
                  if (_isTasksCategory) {
                    return _buildTaskCard(
                      context,
                      thought,
                      primaryColor,
                      secondaryColor,
                    );
                  }

                  /// OTHER CATEGORIES
                  return _buildThoughtCard(context, thought, primaryColor);
                },
              ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: FloatingActionButton.extended(
          onPressed: _navigateToAddThought,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Thought',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildThoughtCard(
    BuildContext context,
    Thought thought,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToThoughtDetail(thought),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thought.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildCategoryChip(thought.category),
                    const SizedBox(width: 8),
                    _buildTimeLabel(thought.createdAt),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Thought thought,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Opacity(
        opacity: thought.isCompleted ? 0.55 : 1.0,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _navigateToThoughtDetail(thought),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: thought.isCompleted,
                        activeColor: secondaryColor,
                        onChanged: (value) {
                          if (value != null) {
                            _toggleTaskCompletion(thought, value);
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          thought.text,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                decoration: thought.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildCategoryChip(thought.category),
                      const SizedBox(width: 8),
                      _buildTimeLabel(thought.createdAt),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFbe9b7b).withAlpha(40),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4b3832),
        ),
      ),
    );
  }

  Widget _buildTimeLabel(DateTime time) {
    return Row(
      children: [
        const Icon(Icons.schedule_rounded, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          _formatRelativeTime(time),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    const primaryColor = Color(0xFF4b3832);
    const secondaryColor = Color(0xFF854442);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: secondaryColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: 64,
                color: primaryColor.withAlpha(102),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No thoughts yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: primaryColor.withAlpha(153),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the + button below\nto add your first thought',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: primaryColor.withAlpha(128),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
