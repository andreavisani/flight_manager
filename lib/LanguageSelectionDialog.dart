import 'package:flutter/material.dart';
import 'AppLocalizations.dart';

class LanguageSelectionDialog extends StatelessWidget {
  final Function(Locale) changeLanguage;

  LanguageSelectionDialog({required this.changeLanguage});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)?.translate('select_language') ?? 'Select Language'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('English'),
            onTap: () {
              changeLanguage(Locale('en', 'US'));
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text('Chinese'),
            onTap: () {
              changeLanguage(Locale('zh', 'TW'));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
