import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/data/models/note.dart';
import 'package:task_manager/data/repositories/note_repository.dart';
import 'package:task_manager/presentation/blocs/note/note_event.dart';
import 'package:task_manager/presentation/blocs/note/note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository noteRepository;

  NoteBloc({required this.noteRepository}) : super(NotesLoadingState()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<LoadArchivedNotesEvent>(_onLoadArchivedNotes);
    on<LoadNoteEvent>(_onLoadNote);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<ArchiveNoteEvent>(_onArchiveNote);
    on<UnarchiveNoteEvent>(_onUnarchiveNote);
    on<SearchNotesEvent>(_onSearchNotes);
    on<CleanupExpiredNotesEvent>(_onCleanupExpiredNotes);
    on<UpdateNoteRetentionDaysEvent>(_onUpdateNoteRetentionDays);
  }

  Future<void> _onLoadNotes(LoadNotesEvent event, Emitter<NoteState> emit) async {
    emit(NotesLoadingState());
    try {
      final notes = await noteRepository.getActiveNotes();
      emit(NotesLoadedState(notes));
    } catch (e) {
      emit(NotesErrorState('Failed to load notes: ${e.toString()}'));
    }
  }

  Future<void> _onLoadArchivedNotes(LoadArchivedNotesEvent event, Emitter<NoteState> emit) async {
    emit(NotesLoadingState());
    try {
      final notes = await noteRepository.getArchivedNotes();
      emit(ArchivedNotesLoadedState(notes));
    } catch (e) {
      emit(NotesErrorState('Failed to load archived notes: ${e.toString()}'));
    }
  }

  Future<void> _onLoadNote(LoadNoteEvent event, Emitter<NoteState> emit) async {
    emit(NotesLoadingState());
    try {
      final note = await noteRepository.getNoteById(event.noteId);
      if (note != null) {
        emit(NoteLoadedState(note));
      } else {
        emit(NotesErrorState('Note not found'));
      }
    } catch (e) {
      emit(NotesErrorState('Failed to load note: ${e.toString()}'));
    }
  }

  Future<void> _onAddNote(AddNoteEvent event, Emitter<NoteState> emit) async {
    emit(NotesLoadingState());
    try {
      await noteRepository.addNote(event.note);
      final notes = await noteRepository.getActiveNotes();
      emit(NotesLoadedState(notes));
    } catch (e) {
      emit(NotesErrorState('Failed to add note: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNote(UpdateNoteEvent event, Emitter<NoteState> emit) async {
    emit(NotesLoadingState());
    try {
      await noteRepository.updateNote(event.note);
      
      // If the note is archived, load archived notes, otherwise load active notes
      if (event.note.isArchived) {
        final notes = await noteRepository.getArchivedNotes();
        emit(ArchivedNotesLoadedState(notes));
      } else {
        final notes = await noteRepository.getActiveNotes();
        emit(NotesLoadedState(notes));
      }
    } catch (e) {
      emit(NotesErrorState('Failed to update note: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteNote(DeleteNoteEvent event, Emitter<NoteState> emit) async {
    emit(NotesLoadingState());
    try {
      await noteRepository.deleteNotePermanently(event.noteId);
      
      // If we're deleting from archive, load archived notes, otherwise load active notes
      if (event.fromArchive) {
        final notes = await noteRepository.getArchivedNotes();
        emit(ArchivedNotesLoadedState(notes));
      } else {
        final notes = await noteRepository.getActiveNotes();
        emit(NotesLoadedState(notes));
      }
    } catch (e) {
      emit(NotesErrorState('Failed to delete note: ${e.toString()}'));
    }
  }

  Future<void> _onArchiveNote(ArchiveNoteEvent event, Emitter<NoteState> emit) async {
    emit(NotesLoadingState());
    try {
      await noteRepository.archiveNote(event.noteId);
      final notes = await noteRepository.getActiveNotes();
      emit(NotesLoadedState(notes));
    } catch (e) {
      emit(NotesErrorState('Failed to archive note: ${e.toString()}'));
    }
  }

  Future<void> _onUnarchiveNote(UnarchiveNoteEvent event, Emitter<NoteState> emit) async {
    emit(NotesLoadingState());
    try {
      await noteRepository.unarchiveNote(event.noteId);
      final notes = await noteRepository.getArchivedNotes();
      emit(ArchivedNotesLoadedState(notes));
    } catch (e) {
      emit(NotesErrorState('Failed to unarchive note: ${e.toString()}'));
    }
  }

  Future<void> _onSearchNotes(SearchNotesEvent event, Emitter<NoteState> emit) async {
    emit(NotesLoadingState());
    try {
      final notes = await noteRepository.searchNotes(
        event.query,
        includeArchived: event.includeArchived,
      );
      emit(NotesSearchResultState(notes, event.query));
    } catch (e) {
      emit(NotesErrorState('Failed to search notes: ${e.toString()}'));
    }
  }

  Future<void> _onCleanupExpiredNotes(CleanupExpiredNotesEvent event, Emitter<NoteState> emit) async {
    try {
      await noteRepository.cleanupExpiredNotes();
      
      // If we're in the archive view, refresh it
      if (state is ArchivedNotesLoadedState) {
        final notes = await noteRepository.getArchivedNotes();
        emit(ArchivedNotesLoadedState(notes));
      }
    } catch (e) {
      // Don't emit error state here as this is a background operation
      print('Failed to cleanup expired notes: ${e.toString()}');
    }
  }

  Future<void> _onUpdateNoteRetentionDays(UpdateNoteRetentionDaysEvent event, Emitter<NoteState> emit) async {
    try {
      await noteRepository.setArchiveRetentionDays(event.days);
      
      // Refresh the current state
      if (state is ArchivedNotesLoadedState) {
        add(const LoadArchivedNotesEvent());
      } else if (state is NotesLoadedState) {
        add(const LoadNotesEvent());
      }
    } catch (e) {
      emit(NotesErrorState('Failed to update retention days: ${e.toString()}'));
    }
  }
}
