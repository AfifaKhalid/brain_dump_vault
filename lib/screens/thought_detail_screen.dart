import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/thought.dart';
import '../services/hive_service.dart';

/// Screen for viewing, editing, and deleting a thought
class ThoughtDetailScreen extends StatefulWidget {
  final Thought thought;

  const ThoughtDetailScreen({super.key, required this.thought});

  @override
  State<ThoughtDetailScreen> createState() => _ThoughtDetailScreenState();
}

class _ThoughtDetailScreenState extends State<ThoughtDetailScreen> {
  late TextEditingController _textController;
  late String _selectedCategory;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.thought.text);
    _selectedCategory = widget.thought.category;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Toggle edit mode
  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset to original values if canceling
        _textController.text = widget.thought.text;
        _selectedCategory = widget.thought.category;
      }
    });
  }

  /// Save changes to the thought
  Future<void> _saveChanges() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thought cannot be empty'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final updatedThought = widget.thought.copyWith(
      text: _textController.text.trim(),
      category: _selectedCategory,
    );

    try {
      await HiveService.updateThought(updatedThought);
      setState(() {
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Thought updated!'),
              ],
            ),
            backgroundColor: const Color(0xFF854442),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating thought: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  /// Delete the thought
  Future<void> _deleteThought() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Thought',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to delete this thought?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await HiveService.deleteThought(widget.thought.id);
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Thought deleted'),
              backgroundColor: const Color(0xFF854442),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting thought: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  /// Show dialog to move thought to another category
  Future<void> _moveToCategory() async {
    String? newCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Move to Category',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: HiveService.defaultCategories.map((category) {
              return ListTile(
                title: Text(category),
                leading: Radio<String>(
                  value: category,
                  // ignore: deprecated_member_use
                  groupValue: _selectedCategory,
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    if (value != null) {
                      Navigator.pop(context, value);
                    }
                  },
                ),
                onTap: () {
                  Navigator.pop(context, category);
                },
              );
            }).toList(),
          ),
        );
      },
    );

    if (newCategory != null && newCategory != _selectedCategory) {
      setState(() {
        _selectedCategory = newCategory;
      });
      await _saveChanges();
    }
  }

  /// Get category color
  Color _getCategoryColor() {
    const primaryColor = Color(0xFF4b3832);
    const secondaryColor = Color(0xFF854442);
    const highlightColor = Color(0xFFbe9b7b);

    switch (_selectedCategory) {
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
    final formattedDate = DateFormat(
      'MMM d, y • h:mm a',
    ).format(widget.thought.createdAt);
    final categoryColor = _getCategoryColor();
    const primaryColor = Color(0xFF4b3832);
    const secondaryColor = Color(0xFF854442);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(_isEditing ? 'Edit Thought' : 'Thought'),
        actions: [
          if (_isEditing)
            TextButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.check_rounded),
              label: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(foregroundColor: secondaryColor),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: _toggleEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _deleteThought,
              tooltip: 'Delete',
            ),
          ],
        ],
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.label_rounded, size: 18, color: categoryColor),
                    const SizedBox(width: 8),
                    Text(
                      _selectedCategory,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Date
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: primaryColor.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: primaryColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Thought text
              if (_isEditing)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _textController,
                        maxLines: null,
                        minLines: 12,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: primaryColor.withValues(alpha: 0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: primaryColor.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: secondaryColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF3c2f2f),
                          height: 1.8,
                          letterSpacing: 0.3,
                        ),
                        autofocus: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: primaryColor.withValues(alpha: 0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: primaryColor.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: secondaryColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        items: HiveService.defaultCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _moveToCategory,
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: const Text('Move to Another Category'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: secondaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _toggleEdit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.thought.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.8,
                      letterSpacing: 0.3,
                      color: primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
