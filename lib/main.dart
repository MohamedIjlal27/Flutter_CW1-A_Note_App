import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'constants/app_constants.dart';

import 'providers/label_provider.dart';
import 'providers/note_provider.dart';
import 'screens/all_labels_screen.dart';
import 'screens/all_notes_screen.dart';
import 'screens/app_infor_screen.dart';
import 'screens/drawer_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: ColorsConstant.grayColor,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => LabelProvider()),
      ],
      builder: (context, child) => MaterialApp(
        title: 'Note-App',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: customThemeData(context),
        initialRoute: '/',
        routes: {
          '/': (context) => const AllNotesScreen(),
          DrawerScreen.routeName: (context) => const DrawerScreen(),
          AllLabelsScreen.routeName: (context) => const AllLabelsScreen(),
          AppInforScreen.routeName: (context) => const AppInforScreen(),
          SettingsScreen.routeName: (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
