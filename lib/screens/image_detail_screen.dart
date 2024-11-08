import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../constants/app_constants.dart';

class ImageDetailScreen extends StatefulWidget {
  const ImageDetailScreen({
    super.key,
    required this.index,
    required this.imagePaths,
  });

  final int index;
  final List<String> imagePaths;

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    _currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(widget.imagePaths);
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.imagePaths.length} pictures',
          style: TextStyleConstants.titleAppBarStyle,
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                widget.imagePaths.removeAt(_currentIndex);
                if (widget.imagePaths.isEmpty) {
                  Navigator.of(context).pop();
                }
                if (widget.imagePaths.length == _currentIndex) {
                  _currentIndex--;
                }
              });
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SizedBox(
        child: Hero(
          tag: 'viewImg$_currentIndex',
          child: PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.imagePaths.length,
            builder: (context, index) => PhotoViewGalleryPageOptions(
              imageProvider: FileImage(
                File(widget.imagePaths[index]),
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 4,
              filterQuality: FilterQuality.high,
            ),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
