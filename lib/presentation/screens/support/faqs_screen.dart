import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          FAQItem(
            question: 'How do I accept delivery requests?',
            answer:
                'You will receive a notification when a new delivery request is available. Tap on the notification to view the details and accept the delivery if you wish to proceed.',
          ),
          FAQItem(
            question: 'How are my earnings calculated?',
            answer:
                'Your earnings are based on the base delivery fee, distance traveled, and any additional incentives or tips from customers. You can view your earnings breakdown in the Earnings section.',
          ),
          FAQItem(
            question: 'What should I do if I face issues during delivery?',
            answer:
                'If you encounter any issues during delivery, you can contact our support team through the Support section. For urgent matters, use the live chat feature for immediate assistance.',
          ),
          FAQItem(
            question: 'How do I update my profile information?',
            answer:
                'Go to the Profile section and tap on the edit icon. You can update your personal information, vehicle details, and other relevant information there.',
          ),
          FAQItem(
            question: 'What documents do I need to maintain?',
            answer:
                'You need to keep your driving license, vehicle registration, and insurance documents up to date. These can be uploaded and managed in the Documents section of your profile.',
          ),
          FAQItem(
            question: 'How do I handle customer complaints?',
            answer:
                'Always maintain professional conduct. If a customer has a complaint, listen to them patiently and try to resolve the issue. If you cannot resolve it, contact support for assistance.',
          ),
        ],
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
