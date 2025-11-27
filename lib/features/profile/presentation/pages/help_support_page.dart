import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Help Section
          _buildSectionHeader('Quick Help'),
          _buildHelpItem(
            icon: Icons.help_outline,
            title: 'Getting Started Guide',
            subtitle: 'Learn how to use MedMind effectively',
            onTap: () => _showGettingStartedGuide(context),
          ),
          _buildHelpItem(
            icon: Icons.medication,
            title: 'Adding Medications',
            subtitle: 'How to add and manage your medications',
            onTap: () => _showMedicationGuide(context),
          ),
          _buildHelpItem(
            icon: Icons.notifications,
            title: 'Setting Reminders',
            subtitle: 'Configure medication reminders and alerts',
            onTap: () => _showRemindersGuide(context),
          ),

          // Contact Support Section
          _buildSectionHeader('Contact Support'),
          _buildContactItem(
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'Get help via email',
            onTap: () => _launchEmail(context),
          ),
          _buildContactItem(
            icon: Icons.chat,
            title: 'Live Chat',
            subtitle: 'Chat with our support team',
            onTap: () => _showLiveChat(context),
          ),
          _buildContactItem(
            icon: Icons.phone,
            title: 'Call Support',
            subtitle: 'Speak with our team directly',
            onTap: () => _launchPhone(context),
          ),

          // Resources Section
          _buildSectionHeader('Resources'),
          _buildResourceItem(
            icon: Icons.library_books,
            title: 'Knowledge Base',
            subtitle: 'Browse helpful articles and tutorials',
            onTap: () => _showKnowledgeBase(context),
          ),
          _buildResourceItem(
            icon: Icons.video_library,
            title: 'Video Tutorials',
            subtitle: 'Watch step-by-step video guides',
            onTap: () => _showVideoTutorials(context),
          ),
          _buildResourceItem(
            icon: Icons.bug_report,
            title: 'Report a Bug',
            subtitle: 'Found an issue? Let us know',
            onTap: () => _reportBug(context),
          ),
          _buildResourceItem(
            icon: Icons.lightbulb,
            title: 'Feature Request',
            subtitle: 'Suggest new features for MedMind',
            onTap: () => _suggestFeature(context),
          ),

          // Emergency Section
          _buildSectionHeader('Emergency Information'),
          Card(
            color: Colors.red.withOpacity(0.1),
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text(
                'Medical Emergency',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'If this is a medical emergency, please call emergency services immediately',
              ),
              onTap: () => _launchEmergencyCall(context),
            ),
          ),

          const SizedBox(height: 32),

          // App Information
          _buildAppInfoSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildResourceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showGettingStartedGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Getting Started Guide'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGuideStep('1. Add Your Medications', 'Tap the + button to add your first medication'),
              _buildGuideStep('2. Set Reminders', 'Configure when you need to take each medication'),
              _buildGuideStep('3. Track Adherence', 'Mark medications as taken and view your history'),
              _buildGuideStep('4. Set Up Profile', 'Add emergency contacts and health information'),
              _buildGuideStep('5. Adjust Settings', 'Customize notifications and app preferences'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String step, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(description),
        ],
      ),
    );
  }

  void _showMedicationGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adding Medications Guide'),
        content: const SingleChildScrollView(
          child: Text(
            'To add a medication:\n\n'
                '1. Go to the Medications tab\n'
                '2. Tap the + button\n'
                '3. Enter medication name\n'
                '4. Add dosage information\n'
                '5. Set schedule and reminders\n'
                '6. Add any special instructions\n\n'
                'You can also scan barcodes for faster entry!',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRemindersGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminders Guide'),
        content: const SingleChildScrollView(
          child: Text(
            'Setting up reminders:\n\n'
                '• Set multiple reminder times per day\n'
                '• Choose different sounds for each medication\n'
                '• Enable snooze for busy times\n'
                '• Set advance notice for preparation\n'
                '• Customize notification preferences in Settings\n\n'
                'Reminders will work even when the app is closed.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@medmind.com',
      queryParameters: {
        'subject': 'MedMind Support Request',
        'body': 'Hello MedMind team,\n\nI need help with:',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email app')),
        );
      }
    }
  }

  void _showLiveChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text('Our live chat support is available Monday-Friday, 9AM-5PM EST. This feature will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(BuildContext context) async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: '+1-800-MED-MIND',
    );

    if (await canLaunchUrl(phoneLaunchUri)) {
      await launchUrl(phoneLaunchUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone app')),
        );
      }
    }
  }

  void _showKnowledgeBase(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Knowledge Base'),
        content: const Text('Our comprehensive knowledge base with articles, FAQs, and troubleshooting guides is coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showVideoTutorials(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Tutorials'),
        content: const Text('Step-by-step video tutorials showing how to use all MedMind features are coming in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _reportBug(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: const Text('Found something that\'s not working right? Let us know so we can fix it!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchEmail(context);
            },
            child: const Text('Report Bug'),
          ),
        ],
      ),
    );
  }

  void _suggestFeature(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suggest a Feature'),
        content: const Text('Have an idea to make MedMind better? We\'d love to hear it!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchEmail(context);
            },
            child: const Text('Suggest Feature'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmergencyCall(BuildContext context) async {
    final Uri emergencyLaunchUri = Uri(
      scheme: 'tel',
      path: '911', // Use local emergency number
    );

    if (await canLaunchUrl(emergencyLaunchUri)) {
      await launchUrl(emergencyLaunchUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch emergency call')),
        );
      }
    }
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Version', '1.0.0'),
            _buildInfoRow('Build Number', '1'),
            _buildInfoRow('Last Updated', 'December 2024'),
            _buildInfoRow('Developer', 'MedMind Team'),
            const SizedBox(height: 16),
            const Text(
              'MedMind helps you manage your medications and stay on track with your health goals.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}