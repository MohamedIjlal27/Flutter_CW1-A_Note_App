import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../functions/future_functions.dart';
import '../providers/label_provider.dart';
import '../providers/note_provider.dart';
import '../utils/app_dialogs.dart';
import '../widgets/custom_list_tile_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/setting';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyleConstants.titleAppBarStyle,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          CustomListTileWidget(
            title: 'Delete All Notes',
            iconData: Icons.note_alt,
            onTap: null,
            trailing: ElevatedButton(
              onPressed: context.watch<NoteProvider>().items.isNotEmpty
                  ? () async {
                      _deleteAllNotes(context);
                      await _deleteFolderContainingImages();
                    }
                  : null,
              child: const Text('Delete All'),
            ),
          ),
          CustomListTileWidget(
            title: 'Delete All Labels',
            iconData: Icons.label,
            onTap: null,
            trailing: ElevatedButton(
              onPressed: context.watch<LabelProvider>().items.isNotEmpty
                  ? () => _deleteAllLabels(context)
                  : null,
              child: const Text('Delete All'),
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: (context.watch<NoteProvider>().items.isNotEmpty ||
                    context.watch<LabelProvider>().items.isNotEmpty)
                ? () => _resetApp(context)
                : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: (context.watch<NoteProvider>().items.isNotEmpty ||
                        context.watch<LabelProvider>().items.isNotEmpty)
                    ? ColorsConstant.blueColor
                    : ColorsConstant.grayColor,
              ),
            ),
            child: const Text('Reset App'),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  void _deleteAllNotes(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: 'Alert',
      content:
          'The notes you have added will be deleted and cannot be recovered.',
      actionName: 'Delete All',
    ).then((bool? result) {
      if (result ?? false) {
        context.read<NoteProvider>().deleteAll();
        deleteCacheDir();
      }
    });
  }

  void _deleteAllLabels(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: 'Alert',
      content:
          'The labels you have added will be deleted and cannot be recovered.',
      actionName: 'Delete All',
    ).then((bool? result) async {
      if (result ?? false) {
        await context.read<LabelProvider>().deleteAll();
        if (context.mounted) {
          unawaited(context.read<NoteProvider>().removeAllLabelContent());
        }
      }
    });
  }

  void _resetApp(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: 'Alert',
      content: 'All your data will be deleted and cannot be recovered.',
      actionName: 'Reset',
    ).then((bool? result) async {
      if (result ?? false) {
        await context.read<LabelProvider>().deleteAll();
        if (context.mounted) {
          await Provider.of<NoteProvider>(context, listen: false).deleteAll();
        }
        await _deleteFolderContainingImages();
        unawaited(deleteCacheDir());
      }
    });
  }

  Future<void> _deleteFolderContainingImages() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/images/');
    if (imagesDir.existsSync()) {
      imagesDir.deleteSync(recursive: true);
    }
  }
}
