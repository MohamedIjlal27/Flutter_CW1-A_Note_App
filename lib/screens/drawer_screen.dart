import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../providers/label_provider.dart';
import '../widgets/custom_list_tile_widget.dart';
import '../widgets/dialog_label_widget.dart';
import 'all_labels_screen.dart';
import 'all_notes_by_label_screen.dart';
import 'app_infor_screen.dart';
import 'settings_screen.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  static const routeName = '/drawer';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ColorsConstant.bgDrawerColor,
      child: ListView(
        children: [
          ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff49BCF6),
                Color(0xff1E2A78),
              ],
            ).createShader(bounds),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: const Text(
                'Note',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          CustomListTileWidget(
            title: 'All Notes',
            iconData: Icons.note_alt,
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          CustomListTileWidget(
            title: 'All Labels',
            iconData: Icons.label,
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(AllLabelsScreen.routeName);
            },
          ),
          const Divider(
            thickness: 1,
            color: ColorsConstant.blueColor,
          ),
          CustomListTileWidget(
            title: 'Create New Label',
            iconData: Icons.add,
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const DialogLabelWidget(),
              );
            },
          ),
          Consumer<LabelProvider>(
            builder: (context, labelProvider, child) => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: labelProvider.items.length,
              itemBuilder: (context, index) => CustomListTileWidget(
                title: labelProvider.items[index].title,
                iconData: Icons.label_outline,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => AllNotesByLabelScreen(
                        label: labelProvider.items[index],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(
            thickness: 1,
            color: ColorsConstant.blueColor,
          ),
          CustomListTileWidget(
            title: 'Settings',
            iconData: Icons.settings,
            onTap: () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
            },
          ),
          CustomListTileWidget(
            title: 'App Info',
            iconData: Icons.info_outline,
            onTap: () {
              Navigator.of(context).pushNamed(AppInforScreen.routeName);
            },
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
