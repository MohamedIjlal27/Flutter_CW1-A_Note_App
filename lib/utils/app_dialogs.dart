import 'package:flutter/material.dart';
import '../constants/assets_path.dart';

Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String actionName,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(actionName),
        ),
      ],
    ),
  );
}

void showNewFeatureNotificationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Alert'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AssetsPath.coding,
            width: 100,
            filterQuality: FilterQuality.high,
            fit: BoxFit.cover,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Feature is under development, coming soon',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    ),
  );
}
