import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:task_manager/data/models/note.dart';
import 'package:task_manager/presentation/blocs/note/note_bloc.dart';
import 'package:task_manager/presentation/blocs/note/note_event.dart';
import 'package:task_manager/presentation/blocs/note/note_state.dart';
import 'package:task_manager/presentation/widgets/common/loading_indicator.dart';
import 'package:task_manager/core/utils/validators.dart';
import 'dart:convert';

class AddEditNoteScreen extends StatefulWidget {
  final bool isEditing;
  final String? noteId;

  const AddEditNoteScreen({
    Key? key,
    required this.isEditing,
    this.noteId,
  }) : super(key: key);

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final List<String> _imagePaths = [];
  final List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();
  
  late quill.QuillController _contentController;
  Color _noteColor = Colors.white;
  
  bool _isLoading = false;
  Note? _originalNote;

  @override
  void initState() {
    super.initState();
    _contentController = quill.QuillController.basic();
    
    if (widget.isEditing && widget.noteId != null) {
      _loadNote();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _loadNote() {
    context.read<NoteBloc>().add(LoadNoteEvent(widget.noteId!));
  }

  void _populateForm(Note note) {
    _originalNote = note;
    _titleController.text = note.title;
    _tags.clear();
    _tags.addAll(note.tags);
    _noteColor = note.color;
    _imagePaths.clear();
    _imagePaths.addAll(note.imagePaths);

    // Load content into the quill editor
    try {
      final contentJson = jsonDecode(note.content);
      _contentController = quill.QuillController(
        document: quill.Document.fromJson(contentJson),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // If the content is not in JSON format, treat it as plain text
      _contentController = quill.QuillController(
        document: quill.Document.fromPlainText(note.content),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Note' : 'Add Note'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(),
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: BlocConsumer<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteLoadedState && widget.isEditing) {
            _populateForm(state.note);
          } else if (state is NotesErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is NotesLoadingState && widget.isEditing && _originalNote == null) {
            return const LoadingIndicator();
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: _noteColor,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          validator: (value) => Validators.validateRequired(value, fieldName: 'Title'),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 300,
                          child: quill.QuillEditor(
                            controller: _contentController,
                            scrollController: ScrollController(),
                            scrollable: true,
                            focusNode: FocusNode(),
                            autoFocus: false,
                            readOnly: false,
                            placeholder: 'Write your note here...',
                            expands: false,
                            padding: EdgeInsets.zero,
                            customStyles: const quill.DefaultStyles(
                              h1: quill.DefaultTextBlockStyle(
                                TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                const VerticalSpacing(16, 0),
                                const VerticalSpacing(0, 0),
                                null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  quill.QuillToolbar.basic(
                    controller: _contentController,
                    showAlignmentButtons: true,
                    showIndent: false,
                    showLink: true,
                    showSearchButton: false,
                    showCodeBlock: false,
                    showQuote: true,
                    showCameraButton: false,
                    showImageButton: false,
                    showVideoButton: false,
                    multiRowsDisplay: false,
                    showHistoryButtons: true,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Note Color:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final color in [
                          Colors.white, 
                          Colors.red.shade100, 
                          Colors.green.shade100, 
                          Colors.blue.shade100, 
                          Colors.yellow.shade100, 
                          Colors.purple.shade100, 
                          Colors.orange.shade100,
                          Colors.pink.shade100,
                          Colors.teal.shade100,
                        ])
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _noteColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _noteColor == color 
                                      ? Colors.blue 
                                      : Colors.grey.shade300,
                                  width: _noteColor == color ? 2 : 1,
                                ),
                              ),
                              child: _noteColor == color
                                  ? const Icon(Icons.check, size: 20)
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tags:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            hintText: 'Add a tag',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_tagController.text.isNotEmpty &&
                              !_tags.contains(_tagController.text.trim())) {
                            setState(() {
                              _tags.add(_tagController.text.trim());
                              _tagController.clear();
                            });
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final tag in _tags)
                        Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _tags.remove(tag);
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        widget.isEditing ? 'Update Note' : 'Add Note',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Convert the quill document to JSON
      final contentJson = jsonEncode(_contentController.document.toDelta().toJson());
      
      if (widget.isEditing && widget.noteId != null && _originalNote != null) {
        final note = Note(
          id: widget.noteId,
          title: _titleController.text,
          content: contentJson,
          createdAt: _originalNote!.createdAt,
          updatedAt: DateTime.now(),
          tags: _tags,
          color: _noteColor,
          imagePaths: _imagePaths,
          isArchived: _originalNote!.isArchived,
          archivedAt: _originalNote!.archivedAt,
          scheduledDeletionDate: _originalNote!.scheduledDeletionDate,
        );
        
        context.read<NoteBloc>().add(UpdateNoteEvent(note));
      } else {
        final note = Note(
          title: _titleController.text,
          content: contentJson,
          tags: _tags,
          color: _noteColor,
          imagePaths: _imagePaths,
        );
        
        context.read<NoteBloc>().add(AddNoteEvent(note));
      }
      
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<NoteBloc>().add(DeleteNoteEvent(widget.noteId!));
                Navigator.pop(context);
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
