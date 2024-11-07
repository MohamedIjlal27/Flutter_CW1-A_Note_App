import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/unordered_list_widget.dart';

class AppInforScreen extends StatelessWidget {
  const AppInforScreen({super.key});

  static const routeName = '/app-infor';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'App Info',
          style: TextStyleConstants.titleAppBarStyle,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            UnorderedListWidget(
              contentList: [
                Content(
                  content:
                      'This app is made for educational purposes only, not for commercial purposes.',
                ),
              ],
            ),
            UnorderedListWidget(
              contentList: [
                Content(
                  content: 'Images used in the application are not owned by me',
                ),
              ],
            ),
            UnorderedListWidget(
              contentList: [
                Content(
                  content:
                      'The codes are not fully owned by me; I referred to the official Flutter documentation to get some help to configure the providers, UI and other things: "https://docs.flutter.dev/ui".',
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
