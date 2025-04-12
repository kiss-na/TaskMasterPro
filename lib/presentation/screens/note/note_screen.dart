import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/data/models/note.dart';
import 'package:task_manager/presentation/blocs/note/note_bloc.dart';
import 'package:task_manager/presentation/blocs/note/note_event.dart';
import 'package:task_manager/presentation/blocs/note/note_state.dart';
import 'package:task_manager/presentation/widgets/note/note_grid_item.dart';
import 'package:task_manager/presentation/widgets/common/empty_state.dart';
import 'package:task_manager/presentation/widgets/common/error_state.dart';
import 'package:task_manager/presentation/widgets/common/loading_indicator.dart';
import 'package:task_manager/config/routes.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadNotes() {
    context.read<NoteBloc>().add(const LoadNotesEvent());
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _loadNotes();
      }
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _loadNotes();
    } else {
      context.read<NoteBloc>().add(SearchNotesEvent(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _onSearchChanged,
                autofocus: true,
              )
            : const Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'archived') {
                Navigator.pushNamed(context, AppRoutes.archivedNotes);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'archived',
                  child: Text('View Archive'),
                ),
              ];
            },
          ),
        ],
      ),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state is NotesLoadingState) {
            return const LoadingIndicator();
          } else if (state is NotesLoadedState) {
            if (state.notes.isEmpty) {
              return const EmptyState(
                icon: Icons.note,
                message: 'No notes yet',
                description: 'Tap the + button to create a new note',
              );
            }
            
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];
                  return NoteGridItem(
                    note: note,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.editNote,
                        arguments: {'noteId': note.id},
                      );
                    },
                    onLongPress: () {
                      _showNoteOptions(note);
                    },
                  );
                },
              ),
            );
          } else if (state is NotesSearchResultState) {
            if (state.searchResults.isEmpty) {
              return EmptyState(
                icon: Icons.search,
                message: 'No results found',
                description: 'No notes match "${state.query}"',
              );
            }
            
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.searchResults.length,
                itemBuilder: (context, index) {
                  final note = state.searchResults[index];
                  return NoteGridItem(
                    note: note,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.editNote,
                        arguments: {'noteId': note.id},
                      );
                    },
                    onLongPress: () {
                      _showNoteOptions(note);
                    },
                  );
                },
              ),
            );
          } else if (state is NotesErrorState) {
            return ErrorState(
              message: state.message,
              onRetry: _loadNotes,
            );
          } else {
            return const EmptyState(
              icon: Icons.error_outline,
              message: 'Unknown state',
              description: 'Something went wrong',
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addNote);
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Note',
      ),
    );
  }

  void _showNoteOptions(Note note) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.editNote,
                    arguments: {'noteId': note.id},
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive),
                title: const Text('Archive'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<NoteBloc>().add(ArchiveNoteEvent(note.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note archived')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(note);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: Text('Are you sure you want to delete "${note.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<NoteBloc>().add(DeleteNoteEvent(note.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note deleted')),
                );
              },
              child: const Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }
}
