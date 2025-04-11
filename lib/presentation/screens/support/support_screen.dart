import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'faqs_screen.dart';
import 'issue_report_screen.dart';
import 'live_chat_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@dashly.com',
      queryParameters: {
        'subject': 'Support Request - Dashly Delivery',
        'body': 'Hello, I need help with...',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch email client';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need Help?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Our support team is here to help you with any issues you may be experiencing.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            _buildSupportOption(
              context,
              'FAQs',
              'Find answers to commonly asked questions',
              Icons.question_answer,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQsScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              context,
              'Contact Us',
              'Get in touch with our support team',
              Icons.email,
              () async {
                try {
                  await _launchEmail();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not launch email client'),
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              context,
              'Report an Issue',
              'Report a bug or technical issue',
              Icons.bug_report,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const IssueReportScreen()),
                );
              },
            ),
            const Spacer(),
            CustomButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LiveChatScreen()),
                );
              },
              text: 'Start Live Chat',
              icon: Icons.chat,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
