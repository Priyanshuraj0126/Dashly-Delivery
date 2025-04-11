import 'package:dashly_delivery/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../widgets/custom_list_tile.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView.builder(
            itemCount: Language.values.length,
            itemBuilder: (context, index) {
              final language = Language.values[index];
              return CustomListTile(
                title: Text(language.name),
                trailing: Radio<Language>(
                  value: language,
                  groupValue: settings.currentLanguage,
                  onChanged: (Language? value) {
                    if (value != null) {
                      settings.setLanguage(value);
                    }
                  },
                ),
                onTap: () {
                  settings.setLanguage(language);
                },
              );
            },
          );
        },
      ),
    );
  }
}
