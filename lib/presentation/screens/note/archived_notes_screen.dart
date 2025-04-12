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

class ArchivedNotesScreen extends StatefulWidget {
  const ArchivedNotesScreen({Key? key}) : super(key: key);

  @override
  State<ArchivedNotesScreen> createState() => _ArchivedNotesScreenState();
}

class _ArchivedNotesScreenState extends State<ArchivedNotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _retentionDays = 30; // Default value

  @override
  void initState() {
    super.initState();
    _loadArchivedNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadArchivedNotes() {
    context.read<NoteBloc>().add(const LoadArchivedNotesEvent());
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _loadArchivedNotes();
      }
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _loadArchivedNotes();
    } else {
      context.read<NoteBloc>().add(SearchNotesEvent(query, includeArchived: true));
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
                  hintText: 'Search archived notes...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _onSearchChanged,
                autofocus: true,
              )
            : const Text('Archived Notes'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showArchiveSettings,
          ),
        ],
      ),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state is NotesLoadingState) {
            return const LoadingIndicator();
          } else if (state is ArchivedNotesLoadedState) {
            if (state.archivedNotes.isEmpty) {
              return const EmptyState(
                icon: Icons.archive,
                message: 'No archived notes',
                description: 'Your archived notes will appear here',
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
                itemCount: state.archivedNotes.length,
                itemBuilder: (context, index) {
                  final note = state.archivedNotes[index];
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
                    showArchiveInfo: true,
                  );
                },
              ),
            );
          } else if (state is NotesSearchResultState) {
            if (state.searchResults.isEmpty) {
              return EmptyState(
                icon: Icons.search,
                message: 'No results found',
                description: 'No archived notes match "${state.query}"',
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
                  if (note.isArchived) {
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
                      showArchiveInfo: true,
                    );
                  } else {
                    return const SizedBox.shrink(); // Skip non-archived notes
                  }
                },
              ),
            );
          } else if (state is NotesErrorState) {
            return ErrorState(
              message: state.message,
              onRetry: _loadArchivedNotes,
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
                leading: const Icon(Icons.unarchive),
                title: const Text('Unarchive'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<NoteBloc>().add(UnarchiveNoteEvent(note.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note unarchived')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('View/Edit'),
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
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Permanently', style: TextStyle(color: Colors.red)),
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
          title: const Text('Delete Note Permanently'),
          content: Text(
            'Are you sure you want to delete "${note.title}" permanently? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<NoteBloc>().add(DeleteNoteEvent(note.id, fromArchive: true));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note permanently deleted')),
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

  void _showArchiveSettings() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Archive Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Auto-delete archived notes after:',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _retentionDays.toDouble(),
                      min: 7,
                      max: 365,
                      divisions: 358,
                      label: _retentionDays.toString(),
                      onChanged: (double value) {
                        setState(() {
                          _retentionDays = value.round();
                        });
                      },
                    ),
                    Center(
                      child: Text(
                        '$_retentionDays days',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<NoteBloc>().add(
                                UpdateNoteRetentionDaysEvent(_retentionDays),
                              );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Archive settings updated'),
                            ),
                          );
                        },
                        child: const Text('Save Settings'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          context.read<NoteBloc>().add(
                                const CleanupExpiredNotesEvent(),
                              );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cleaned up expired notes'),
                            ),
                          );
                        },
                        child: const Text('Clean up expired notes now'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
