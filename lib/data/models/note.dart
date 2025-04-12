import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 3)
class Note extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String content;
  
  @HiveField(3)
  DateTime createdAt;
  
  @HiveField(4)
  DateTime updatedAt;
  
  @HiveField(5)
  List<String> tags;
  
  @HiveField(6)
  Color color;
  
  @HiveField(7)
  List<String> imagePaths;
  
  @HiveField(8)
  bool isArchived;
  
  @HiveField(9)
  DateTime? archivedAt;
  
  @HiveField(10)
  DateTime? scheduledDeletionDate;
  
  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Color? color,
    List<String>? imagePaths,
    this.isArchived = false,
    this.archivedAt,
    this.scheduledDeletionDate,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        tags = tags ?? [],
        color = color ?? Colors.white,
        imagePaths = imagePaths ?? [];

  // Create a copy of the note with modified fields
  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    List<String>? tags,
    Color? color,
    List<String>? imagePaths,
    bool? isArchived,
    DateTime? archivedAt,
    DateTime? scheduledDeletionDate,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      tags: tags ?? this.tags,
      color: color ?? this.color,
      imagePaths: imagePaths ?? this.imagePaths,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      scheduledDeletionDate: scheduledDeletionDate ?? this.scheduledDeletionDate,
    );
  }

  // Archive the note
  Note archive(int retentionDays) {
    final now = DateTime.now();
    return copyWith(
      isArchived: true,
      archivedAt: now,
      scheduledDeletionDate: now.add(Duration(days: retentionDays)),
    );
  }

  // Unarchive the note
  Note unarchive() {
    return copyWith(
      isArchived: false,
      archivedAt: null,
      scheduledDeletionDate: null,
    );
  }

  // Check if note has images
  bool hasImages() {
    return imagePaths.isNotEmpty;
  }

  // Check if note should be deleted based on retention period
  bool shouldBeDeleted() {
    if (!isArchived || scheduledDeletionDate == null) return false;
    return DateTime.now().isAfter(scheduledDeletionDate!);
  }

  // Calculate days remaining before deletion
  int daysRemainingBeforeDeletion() {
    if (!isArchived || scheduledDeletionDate == null) return -1;
    return scheduledDeletionDate!.difference(DateTime.now()).inDays;
  }
}
