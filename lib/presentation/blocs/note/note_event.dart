import 'package:equatable/equatable.dart';
import 'package:task_manager/data/models/note.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotesEvent extends NoteEvent {
  const LoadNotesEvent();
}

class LoadArchivedNotesEvent extends NoteEvent {
  const LoadArchivedNotesEvent();
}

class LoadNoteEvent extends NoteEvent {
  final String noteId;

  const LoadNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class AddNoteEvent extends NoteEvent {
  final Note note;

  const AddNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class UpdateNoteEvent extends NoteEvent {
  final Note note;

  const UpdateNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class DeleteNoteEvent extends NoteEvent {
  final String noteId;
  final bool fromArchive;

  const DeleteNoteEvent(this.noteId, {this.fromArchive = false});

  @override
  List<Object?> get props => [noteId, fromArchive];
}

class ArchiveNoteEvent extends NoteEvent {
  final String noteId;

  const ArchiveNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class UnarchiveNoteEvent extends NoteEvent {
  final String noteId;

  const UnarchiveNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class SearchNotesEvent extends NoteEvent {
  final String query;
  final bool includeArchived;

  const SearchNotesEvent(this.query, {this.includeArchived = false});

  @override
  List<Object?> get props => [query, includeArchived];
}

class CleanupExpiredNotesEvent extends NoteEvent {
  const CleanupExpiredNotesEvent();
}

class UpdateNoteRetentionDaysEvent extends NoteEvent {
  final int days;

  const UpdateNoteRetentionDaysEvent(this.days);

  @override
  List<Object?> get props => [days];
}
