import 'package:flutter/material.dart';
import 'package:task_manager/data/models/note.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'dart:convert';

class NoteGridItem extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool showArchiveInfo;

  const NoteGridItem({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    this.showArchiveInfo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: note.color,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildNoteContent(),
              ),
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 24,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: note.tags.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          note.tags[index],
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (showArchiveInfo && note.isArchived && note.scheduledDeletionDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Auto-delete in ${note.daysRemainingBeforeDeletion()} days',
                  style: TextStyle(
                    fontSize: 11,
                    color: note.daysRemainingBeforeDeletion() < 7 ? Colors.red : Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteContent() {
    try {
      // Try to parse content as Quill Delta JSON
      final contentJson = jsonDecode(note.content);
      final document = Document.fromJson(contentJson);
      
      return QuillEditor(
        controller: QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        ),
        scrollController: ScrollController(),
        scrollable: true,
        focusNode: FocusNode(),
        autoFocus: false,
        readOnly: true,
        expands: false,
        padding: EdgeInsets.zero,
        showCursor: false,
      );
    } catch (e) {
      // If parsing fails, display as plain text
      return Text(
        note.content,
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      );
    }
  }
}
