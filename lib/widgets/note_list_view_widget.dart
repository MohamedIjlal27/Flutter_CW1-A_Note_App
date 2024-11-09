// Flutter Documentation (Google), (2024) Widget catalog.
//Available at: https://flutter.dev/docs/ui/widgets
//(Accessed: 10 October 2024).

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../functions/future_functions.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../screens/edit_note_screen.dart';
import 'note_card_widget.dart';

class NoteListViewWidget extends StatelessWidget {
  const NoteListViewWidget({
    super.key,
    required this.notes,
    required this.viewMode,
    this.scaffoldContext,
  });

  final List<Note> notes;
  final String viewMode;
  final BuildContext? scaffoldContext;

  @override
  Widget build(BuildContext context) {
    return (viewMode == ViewMode.staggeredGrid.name)
        ? StaggeredGridView.countBuilder(
            crossAxisCount: 2,
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
            itemCount: notes.length,
            staggeredTileBuilder: (index) {
              return const StaggeredTile.fit(1);
            },
            itemBuilder: (context, index) => _noteItem(context, index),
          )
        : ListView.builder(
            itemCount: notes.length,
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
            itemBuilder: (context, index) => _noteItem(context, index),
          );
  }

  Widget _noteItem(BuildContext context, int index) {
    final currentNote = notes[index];
    final noteProvider = context.read<NoteProvider>();

    return GestureDetector(
      onTap: () async {
        final Note? result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditNoteScreen(
              note: currentNote,
            ),
          ),
        );
        if (result != null) {
          bool isUndo = false;
          ScaffoldMessenger.of(scaffoldContext!).hideCurrentSnackBar();
          ScaffoldMessenger.of(scaffoldContext!).showSnackBar(
            SnackBar(
              content: const Text(
                'The note has been deleted!',
              ),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  isUndo = true;
                  noteProvider.add(result);
                },
              ),
            ),
          );
          Future.delayed(const Duration(seconds: 3), () {
            if (!isUndo) {
              deleteFileList(
                result.imagePaths.map((path) => File(path)).toList(),
              );
            }
          });
        }
        await refreshOrGetData(scaffoldContext!);
      },
      child: NoteCardWidget(
        note: currentNote,
      ),
    );
  }
}
