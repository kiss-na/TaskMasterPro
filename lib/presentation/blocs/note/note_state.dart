import 'package:equatable/equatable.dart';
import 'package:task_manager/data/models/note.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

class NotesLoadingState extends NoteState {}

class NotesLoadedState extends NoteState {
  final List<Note> notes;

  const NotesLoadedState(this.notes);

  @override
  List<Object?> get props => [notes];
}

class ArchivedNotesLoadedState extends NoteState {
  final List<Note> archivedNotes;

  const ArchivedNotesLoadedState(this.archivedNotes);

  @override
  List<Object?> get props => [archivedNotes];
}

class NoteLoadedState extends NoteState {
  final Note note;

  const NoteLoadedState(this.note);

  @override
  List<Object?> get props => [note];
}

class NotesSearchResultState extends NoteState {
  final List<Note> searchResults;
  final String query;

  const NotesSearchResultState(this.searchResults, this.query);

  @override
  List<Object?> get props => [searchResults, query];
}

class NotesErrorState extends NoteState {
  final String message;

  const NotesErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
