import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class NoteFormWidget extends StatelessWidget {
  const NoteFormWidget({
    super.key,
    required this.title,
    required this.content,
    required this.onChangedTitle,
    required this.onChangedContent,
  });

  final String title;
  final String content;
  final ValueChanged onChangedTitle;
  final ValueChanged onChangedContent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextFormField(
          maxLines: null,
          initialValue: title,
          style: TextStyleConstants.titleStyle1,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Title',
          ),
          validator: (value) => value!.length > 50
              ? 'Title should not exceed 50 characters'
              : null,
          onChanged: onChangedTitle,
          textInputAction: TextInputAction.next,
        ),
        TextFormField(
          maxLines: null,
          initialValue: content,
          style: TextStyleConstants.contentStyle2,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Note',
          ),
          validator: (value) => value!.isEmpty ? 'Blank note' : null,
          onChanged: onChangedContent,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
