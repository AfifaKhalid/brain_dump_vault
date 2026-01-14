import 'package:hive/hive.dart';

/// Thought model representing a single thought entry
/// Stores id, text, category, creation timestamp,
/// and completion state (used for Tasks category)
class Thought extends HiveObject {
  String id;
  String text;
  String category;
  DateTime createdAt;

  /// Used only for Tasks category
  bool isCompleted;

  Thought({
    required this.id,
    required this.text,
    required this.category,
    required this.createdAt,
    this.isCompleted = false,
  });

  /// Create a copy of this thought with updated fields
  Thought copyWith({
    String? id,
    String? text,
    String? category,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return Thought(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Convert Thought to Map for easier manipulation
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  /// Create Thought from Map
  factory Thought.fromMap(Map<String, dynamic> map) {
    return Thought(
      id: map['id'] as String,
      text: map['text'] as String,
      category: map['category'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}

/// TypeAdapter for Thought to work with Hive
class ThoughtAdapter extends TypeAdapter<Thought> {
  @override
  final int typeId = 0;

  @override
  Thought read(BinaryReader reader) {
    final id = reader.readString();
    final text = reader.readString();
    final category = reader.readString();
    final createdAt = DateTime.parse(reader.readString());

    /// Backward-safe read:
    /// Old entries won't have isCompleted stored
    final isCompleted = reader.availableBytes > 0 ? reader.readBool() : false;

    return Thought(
      id: id,
      text: text,
      category: category,
      createdAt: createdAt,
      isCompleted: isCompleted,
    );
  }

  @override
  void write(BinaryWriter writer, Thought obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.text);
    writer.writeString(obj.category);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeBool(obj.isCompleted);
  }
}
