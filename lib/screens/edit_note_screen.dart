import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../constants/assets_path.dart';
import '../functions/future_functions.dart';
import '../functions/picker_functions.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../utils/app_dialogs.dart';
import '../widgets/label_card_widget.dart';
import '../widgets/note_form_widget.dart';
import 'image_detail_screen.dart';
import 'pick_label_screen.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({
    super.key,
    this.note,
    this.defaultLabel,
  });

  final Note? note;
  final String? defaultLabel;

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();

  // list of temporarily deleted image files
  final List<File> _tmpDeletedImageFiles = [];

  // list of temporarily added image files
  final List<File> _tmpAddedImageFiles = [];

  late String _title;
  late String _content;
  late String _label;
  late Color _bgColor;
  late List<String> _imagePaths;

  late String _defaultLabel;

  @override
  void initState() {
    super.initState();
    _defaultLabel = widget.defaultLabel ?? '';

    _title = widget.note?.title ?? '';
    _content = widget.note?.content ?? '';
    _bgColor = widget.note?.bgColor ?? ColorsConstant.bgScaffoldColor;
    _imagePaths = widget.note?.imagePaths ?? [];

    if (_defaultLabel.isNotEmpty) {
      _label = _defaultLabel;
    } else {
      _label = widget.note?.label ?? '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: ColorsConstant.grayColor,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(systemNavigationBarColor: _bgColor),
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
          Navigator.of(context).pop();
          await deleteFileList(_tmpAddedImageFiles);
        },
        child: Scaffold(
          backgroundColor: _bgColor,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
                deleteFileList(_tmpAddedImageFiles);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () => _addImageFromCamera(ImageSource.camera),
              ),
              IconButton(
                onPressed: _addManyImagesFromGallery,
                icon: const Icon(Icons.photo),
              ),
              IconButton(
                onPressed: _deleteNote,
                icon: const Icon(Icons.delete),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: _saveNote,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
          body: ListView(
            children: [
              ImagesStaggeredGridView(
                imagePaths: _imagePaths,
                tmpDeletedImagePaths: _tmpDeletedImageFiles,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: _formKey,
                      child: Container(
                        width: MediaQuery.of(context).size.width *
                            0.9, // Adjust width as needed
                        child: NoteFormWidget(
                          title: _title,
                          content: _content,
                          onChangedTitle: (value) => _title = value,
                          onChangedContent: (value) => _content = value,
                          // maxLines: null, // Remove this line if not supported
                        ),
                      ),
                    ),
                    if (_label.isNotEmpty) LabelCardWidget(title: _label),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SizedBox(
            height: MediaQuery.of(context).size.height * .06,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _defaultLabel.isEmpty ? _addOrChangeLabel : null,
                  icon: const Icon(Icons.label),
                ),
                IconButton(
                  onPressed: () => pickColor(
                    context: context,
                    selectedColor: _bgColor,
                    changeColor: (value) {
                      setState(() {
                        _bgColor = value;
                      });
                    },
                  ),
                  icon: const Icon(Icons.color_lens_outlined),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Edited: ${DateFormat.yMd().format(DateTime.now())}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveNote() async {
    final bool isValid = _formKey.currentState!.validate();

    if (isValid) {
      final bool isUpdate = widget.note != null;

      if (isUpdate) {
        _updateNote();
      } else {
        _addNote();
      }
      Navigator.of(context).pop();
      await deleteFileList(_tmpDeletedImageFiles);
    }
  }

  void _addNote() {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _title.trim(),
      content: _content.trim(),
      createdTime: DateTime.now(),
      label: _label,
      imagePaths: _imagePaths,
      bgColor: _bgColor,
    );

    Provider.of<NoteProvider>(context, listen: false).add(note);
  }

  void _updateNote() {
    final note = widget.note!.copy(
      title: _title.trim(),
      content: _content.trim(),
      createdTime: DateTime.now(),
      label: _label,
      imagePaths: _imagePaths,
      bgColor: _bgColor,
    );

    Provider.of<NoteProvider>(context, listen: false).update(note);
  }

  Future<void> _deleteNote() async {
    if (widget.note != null) {
      final bool? action = await showConfirmDialog(
        context: context,
        title: 'Remove Note?',
        content: 'Are you sure you want to delete this note?',
        actionName: 'Remove',
      );
      if (action ?? false) {
        await context.read<NoteProvider>().delete(widget.note!.id);

        // return the note so it can be undone
        Navigator.of(context).pop(widget.note);

        await deleteFileList(_tmpAddedImageFiles);
      }
    } else {
      Navigator.of(context).pop(widget.note);
      await deleteFileList(_tmpAddedImageFiles);
    }
  }

  Future<void> _addImageFromCamera(ImageSource camera) async {
    try {
      final File? imgFile = await pickImage(ImageSource.camera);

      if (imgFile == null) {
        return;
      }

      setState(() {
        _imagePaths.insert(0, imgFile.path);
        _tmpAddedImageFiles.add(imgFile);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _addManyImagesFromGallery() async {
    try {
      final List<File>? imgFileList = await pickManyImages();

      if (imgFileList == null) {
        return;
      }

      final imgPathList = imgFileList.map((e) => e.path).toList();

      setState(() {
        _imagePaths.insertAll(0, imgPathList);
        _tmpAddedImageFiles.addAll(imgFileList);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _addOrChangeLabel() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PickLabelScreen(labelTitle: _label),
      ),
    );
    setState(() {
      _label = result;
    });
  }
}

class ImagesStaggeredGridView extends StatefulWidget {
  const ImagesStaggeredGridView({
    super.key,
    required this.imagePaths,
    required this.tmpDeletedImagePaths,
  });

  final List<String> imagePaths;
  final List<File> tmpDeletedImagePaths;

  @override
  State<ImagesStaggeredGridView> createState() =>
      _ImagesStaggeredGridViewState();
}

class _ImagesStaggeredGridViewState extends State<ImagesStaggeredGridView> {
  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) {
      return const SizedBox.shrink();
    } else {
      return StaggeredGridView.countBuilder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 3,
        staggeredTileBuilder: (index) {
          final int total = widget.imagePaths.length;

          return getStaggeredTile(total: total, index: index);
        },
        itemBuilder: (context, index) => InkWell(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImageDetailScreen(
                  index: index,
                  imagePaths: widget.imagePaths,
                ),
              ),
            );
            setState(() {});
          },
          onLongPress: () async {
            final bool? result = await showConfirmDialog(
              context: context,
              title: 'Delete Photos?',
              content: 'You want to remove this image?',
              actionName: 'Remove',
            );
            if (result ?? false) {
              setState(() {
                widget.tmpDeletedImagePaths.add(File(widget.imagePaths[index]));
                widget.imagePaths.removeAt(index);
              });
            }
          },
          child: Hero(
            tag: 'viewImg$index',
            child: FadeInImage(
              placeholder: AssetImage(AssetsPath.placeholderImage),
              fadeInDuration: const Duration(milliseconds: 500),
              image: FileImage(
                File(widget.imagePaths[index]),
              ),
              fit: BoxFit.cover,
              placeholderFit: BoxFit.cover,
            ),
          ),
        ),
        itemCount: widget.imagePaths.length,
      );
    }
  }
}
