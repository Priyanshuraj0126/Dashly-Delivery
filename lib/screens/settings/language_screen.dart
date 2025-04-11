import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_localizations_helper.dart';
import '../../providers/settings_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.language),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildLanguageOption(
                context,
                'en',
                context.l10n.english,
                settings,
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(
                context,
                'hi',
                context.l10n.hindi,
                settings,
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(
                context,
                'mr',
                context.l10n.marathi,
                settings,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageCode,
    String languageName,
    SettingsProvider settings,
  ) {
    final isSelected = settings.selectedLanguage == languageCode;

    return Material(
      color:
          isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => settings.setLanguage(languageCode),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  languageName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
