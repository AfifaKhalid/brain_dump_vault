import 'package:hive_flutter/hive_flutter.dart';
import '../models/thought.dart';

/// Service class for managing Hive storage operations
/// Handles initialization, CRUD operations, and search functionality
class HiveService {
  static const String _thoughtsBoxName = 'thoughts';
  static const List<String> _defaultCategories = [
    'Ideas',
    'Worries',
    'Tasks',
    'Random',
  ];

  static Box<Thought>? _thoughtsBox;

  /// Initialize Hive and open the thoughts box
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register the Thought adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ThoughtAdapter());
    }

    // Open the thoughts box
    _thoughtsBox = await Hive.openBox<Thought>(_thoughtsBoxName);
  }

  /// Get the thoughts box
  static Box<Thought> get thoughtsBox {
    if (_thoughtsBox == null) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    return _thoughtsBox!;
  }

  /// Get all default categories
  static List<String> get defaultCategories => _defaultCategories;

  /// Add a new thought
  static Future<void> addThought(Thought thought) async {
    await thoughtsBox.put(thought.id, thought);
  }

  /// Get all thoughts
  static List<Thought> getAllThoughts() {
    return thoughtsBox.values.toList();
  }

  /// Get thoughts by category
  static List<Thought> getThoughtsByCategory(String category) {
    return thoughtsBox.values
        .where((thought) => thought.category == category)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
  }

  /// Get a single thought by id
  static Thought? getThought(String id) {
    return thoughtsBox.get(id);
  }

  /// Update an existing thought
  static Future<void> updateThought(Thought thought) async {
    await thoughtsBox.put(thought.id, thought);
  }

  /// Delete a thought
  static Future<void> deleteThought(String id) async {
    await thoughtsBox.delete(id);
  }

  /// Search thoughts by keyword (searches in text)
  static List<Thought> searchThoughts(String query) {
    if (query.isEmpty) {
      return getAllThoughts();
    }

    final lowerQuery = query.toLowerCase();
    return thoughtsBox.values
        .where((thought) =>
            thought.text.toLowerCase().contains(lowerQuery) ||
            thought.category.toLowerCase().contains(lowerQuery))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get count of thoughts per category
  static Map<String, int> getCategoryCounts() {
    final Map<String, int> counts = {};
    for (final thought in thoughtsBox.values) {
      counts[thought.category] = (counts[thought.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Get count for a specific category
  static int getCategoryCount(String category) {
    return thoughtsBox.values
        .where((thought) => thought.category == category)
        .length;
  }

  /// Clear all thoughts (useful for testing or reset)
  static Future<void> clearAllThoughts() async {
    await thoughtsBox.clear();
  }
}
