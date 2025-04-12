import 'package:hive/hive.dart';
import 'package:task_manager/data/models/note.dart';

class NoteRepository {
  // Hive box names
  static const String activeBoxName = 'notes';
  static const String archivedBoxName = 'archived_notes';
  static const String settingsBoxName = 'settings';
  
  // Default archive retention period in days
  static const int defaultRetentionDays = 30;

  // Get active notes
  Future<List<Note>> getActiveNotes() async {
    final box = await Hive.openBox<Note>(activeBoxName);
    return box.values.toList();
  }

  // Get archived notes
  Future<List<Note>> getArchivedNotes() async {
    final box = await Hive.openBox<Note>(archivedBoxName);
    return box.values.toList();
  }

  // Get note by ID (checks both active and archived)
  Future<Note?> getNoteById(String id, {bool checkArchived = true}) async {
    // Check active notes
    final activeBox = await Hive.openBox<Note>(activeBoxName);
    
    for (final note in activeBox.values) {
      if (note.id == id) {
        return note;
      }
    }
    
    // Check archived notes if requested
    if (checkArchived) {
      final archivedBox = await Hive.openBox<Note>(archivedBoxName);
      
      for (final note in archivedBox.values) {
        if (note.id == id) {
          return note;
        }
      }
    }
    
    return null;
  }

  // Add note
  Future<void> addNote(Note note) async {
    final box = await Hive.openBox<Note>(activeBoxName);
    await box.add(note);
  }

  // Update note
  Future<void> updateNote(Note note) async {
    // Determine which box to check based on archive status
    final boxName = note.isArchived ? archivedBoxName : activeBoxName;
    final box = await Hive.openBox<Note>(boxName);
    
    for (final entry in box.toMap().entries) {
      if (box.get(entry.key)?.id == note.id) {
        await box.put(entry.key, note);
        break;
      }
    }
  }

  // Delete note permanently
  Future<void> deleteNotePermanently(String id) async {
    // Check both boxes
    final activeBox = await Hive.openBox<Note>(activeBoxName);
    final archivedBox = await Hive.openBox<Note>(archivedBoxName);
    
    // Check active box
    for (final entry in activeBox.toMap().entries) {
      if (activeBox.get(entry.key)?.id == id) {
        await activeBox.delete(entry.key);
        return;
      }
    }
    
    // Check archived box
    for (final entry in archivedBox.toMap().entries) {
      if (archivedBox.get(entry.key)?.id == id) {
        await archivedBox.delete(entry.key);
        return;
      }
    }
  }

  // Archive note
  Future<void> archiveNote(String id) async {
    final note = await getNoteById(id, checkArchived: false);
    
    if (note != null) {
      final retentionDays = await getArchiveRetentionDays();
      final archivedNote = note.archive(retentionDays);
      
      // Add to archived notes
      final archivedBox = await Hive.openBox<Note>(archivedBoxName);
      await archivedBox.add(archivedNote);
      
      // Remove from active notes
      final activeBox = await Hive.openBox<Note>(activeBoxName);
      for (final entry in activeBox.toMap().entries) {
        if (activeBox.get(entry.key)?.id == id) {
          await activeBox.delete(entry.key);
          break;
        }
      }
    }
  }

  // Unarchive note
  Future<void> unarchiveNote(String id) async {
    final note = await getNoteById(id);
    
    if (note != null && note.isArchived) {
      final unarchivedNote = note.unarchive();
      
      // Add to active notes
      final activeBox = await Hive.openBox<Note>(activeBoxName);
      await activeBox.add(unarchivedNote);
      
      // Remove from archived notes
      final archivedBox = await Hive.openBox<Note>(archivedBoxName);
      for (final entry in archivedBox.toMap().entries) {
        if (archivedBox.get(entry.key)?.id == id) {
          await archivedBox.delete(entry.key);
          break;
        }
      }
    }
  }

  // Clean up expired archived notes
  Future<void> cleanupExpiredNotes() async {
    final archivedBox = await Hive.openBox<Note>(archivedBoxName);
    final notesToDelete = <String>{};
    
    // Find notes that should be deleted
    for (final entry in archivedBox.toMap().entries) {
      final note = archivedBox.get(entry.key);
      if (note != null && note.shouldBeDeleted()) {
        notesToDelete.add(note.id);
      }
    }
    
    // Delete identified notes
    for (final id in notesToDelete) {
      await deleteNotePermanently(id);
    }
    
    return;
  }

  // Get archive retention period from settings
  Future<int> getArchiveRetentionDays() async {
    final settingsBox = await Hive.openBox(settingsBoxName);
    return settingsBox.get('note_retention_days', defaultValue: defaultRetentionDays);
  }

  // Set archive retention period
  Future<void> setArchiveRetentionDays(int days) async {
    final settingsBox = await Hive.openBox(settingsBoxName);
    await settingsBox.put('note_retention_days', days);
  }
  
  // Search notes
  Future<List<Note>> searchNotes(String query, {bool includeArchived = false}) async {
    final activeNotes = await getActiveNotes();
    final List<Note> archivedNotes = includeArchived ? await getArchivedNotes() : [];
    
    final allNotes = [...activeNotes, ...archivedNotes];
    
    if (query.isEmpty) {
      return allNotes;
    }
    
    final lowerCaseQuery = query.toLowerCase();
    
    return allNotes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(lowerCaseQuery);
      final contentMatch = note.content.toLowerCase().contains(lowerCaseQuery);
      final tagsMatch = note.tags.any((tag) => tag.toLowerCase().contains(lowerCaseQuery));
      
      return titleMatch || contentMatch || tagsMatch;
    }).toList();
  }
}
