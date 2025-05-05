import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_localizations_helper.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/custom_list_tile.dart';
import 'package:provider/provider.dart';
import '../../blocs/auth/auth_bloc.dart';
import 'language_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          CustomListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(context.l10n.notifications),
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          CustomListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(context.l10n.language),
            trailing: Text(
              settingsProvider
                  .getLanguageName(settingsProvider.selectedLanguage),
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageScreen()),
              );
            },
          ),
          CustomListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(context.l10n.help),
            onTap: () {
              Navigator.pushNamed(context, '/support');
            },
          ),
          CustomListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(context.l10n.about),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          CustomListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              context.l10n.logout,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        context.l10n.logout,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ).then((confirmed) async {
                if (confirmed == true) {
                  final currentContext = context;

                  currentContext.read<AuthBloc>().add(SignOutEvent());

                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      currentContext,
                      '/login',
                      (route) => false,
                    );
                  }
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
